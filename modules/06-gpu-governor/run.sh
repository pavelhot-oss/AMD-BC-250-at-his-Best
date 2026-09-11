#!/usr/bin/env bash
# Module 06 — Overclock GPU via le gouverneur cyan-skillfish.
# Ce module gère le cycle de vie complet : clone, build Rust, et configuration.
set -uo pipefail
BC250_ROOT="${BC250_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${BC250_ROOT}/lib/common.sh"

title "$(t m06_title)"
require_root
require_bc250

if [[ -f "${BC250_ROOT}/logs/.cooling_power_confirmed" ]]; then
    :
else
    warn "$(t common_m01_not_confirmed)"
    confirm "$(t common_continue_anyway_q)" || exit 1
fi

# ------------------------------------------------------------------
# Vérification des dépendances de build (git, make, cargo, pkg-config, libudev)
# ------------------------------------------------------------------
check_build_deps() {
    local missing=()
    for cmd in git make cargo pkg-config; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    # libudev : header requis pour la compilation (check pkg-config commun à toutes les familles)
    pkg-config --exists libudev 2>/dev/null || missing+=("libudev (pkg-config)")

    if [[ ${#missing[@]} -gt 0 ]]; then
        err "$(t m06_missing_deps)"
        for m in "${missing[@]}"; do
            echo "  ❌ $m"
        done
        echo
        local distro; distro="$(detect_distro)"
        case "$distro" in
            arch|cachyos)
                t m06_install_with
                echo "  sudo pacman -S git base-devel rust pkgconf"
                t m06_arch_libudev_note
                ;;
            bazzite-ostree|fedora-ostree)
                t m06_install_with
                echo "  sudo rpm-ostree install rust cargo systemd-devel"
                warn "$(t m06_ostree_build_env)"
                ;;
            fedora)
                t m06_install_with
                echo "  sudo dnf install git make cargo pkgconf systemd-devel"
                ;;
            debian|ubuntu)
                t m06_install_with
                echo "  sudo apt-get update && sudo apt-get install git build-essential cargo pkg-config libudev-dev"
                ;;
            *)
                t m06_unknown_distro_deps "$distro"
                ;;
        esac
        return 1
    fi
    log "$(t m06_deps_ok)"
    return 0
}

if ! check_build_deps; then
    exit 1
fi

# ------------------------------------------------------------------
# Clone / mise à jour du dépôt
# ------------------------------------------------------------------
REPO_DIR="/tmp/bc250-beast-build/cyan-skillfish-governor"
mkdir -p "$(dirname "$REPO_DIR")"
if [[ ! -d "$REPO_DIR" ]]; then
    log "$(t m06_cloning)"
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] git clone --branch smu https://github.com/filippor/cyan-skillfish-governor.git $REPO_DIR"
    else
        git clone --branch smu https://github.com/filippor/cyan-skillfish-governor.git "$REPO_DIR"
    fi
else
    log "$(t m06_repo_update)"
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] git -C $REPO_DIR pull"
    else
        git -C "$REPO_DIR" pull || warn "$(t m06_pull_failed)"
    fi
fi

# ------------------------------------------------------------------
# Compilation (cargo build --release)
# ------------------------------------------------------------------
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m06_dry_build "$REPO_DIR")"
else
    log "$(t m06_building)"
    cd "$REPO_DIR"
    cargo build --release || die "$(t m06_build_failed)"
    log "$(t m06_build_ok "$REPO_DIR/target/release/cyan-skillfish-governor")"
fi

# ------------------------------------------------------------------
# Installation (binaire, enveloppe perf-mode, politique D-Bus, service
# systemd) + configuration dans le format attendu par le gouverneur.
# ------------------------------------------------------------------
# Voltage par défaut : recopie la courbe sûre de l'amont (config.toml),
# en arrondissant au palier supérieur pour ne jamais sous-dimensionner.
_gpu_voltage_table() {
    cat <<'EOF'
500 700
1175 700
1400 750
1600 800
1700 850
1850 900
2000 950
2050 975
2100 1000
2125 1015
2150 1030
2200 1050
2230 1085
2300 1110
2350 1130
EOF
}
default_gpu_voltage() {
    local f="${1:-2000}" volt=1150
    while read -r vf vv; do
        if (( f <= vf )); then volt="$vv"; break; fi
    done < <(_gpu_voltage_table)
    echo "$volt"
}

BIN_DIR="/etc/cyan-skillfish-governor-smu"
CONF_FILE="${BIN_DIR}/config.toml"
BIN_SRC="$REPO_DIR/target/release/cyan-skillfish-governor-smu"
BIN_PATH="${BIN_DIR}/cyan-skillfish-governor-smu"
PERF_MODE_SRC="$REPO_DIR/scripts/cyan-skillfish-performance-mode"
PERF_MODE_PATH="/usr/local/bin/cyan-skillfish-performance-mode"
DBUS_POLICY_SRC="$REPO_DIR/com.cyanskillfish.Governor.conf"
DBUS_POLICY_PATH="/etc/dbus-1/system.d/com.cyanskillfish.Governor.conf"
SERVICE_NAME="cyan-skillfish-governor-smu"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

TARGET_FREQ="${GPU_FREQ_MHZ:-2000}"
TARGET_TEMP="${GPU_TEMP_TARGET_C:-85}"
TARGET_VOLT="${GPU_VOLT_MV:-$(default_gpu_voltage "$TARGET_FREQ")}"

t m06_follow_readme "$REPO_DIR"

if ! confirm "$(t m06_installed_q)"; then
    warn "$(t m06_config_postponed)"
    exit 0
fi

log "$(t m06_generating "$CONF_FILE" "$TARGET_TEMP")"

# Contenu du config.toml (formats attendus par le gouverneur amont :
# section [temperature], et chaque [[safe-points]] doit avoir un voltage).
render_governor_config() {
    t m06_toml_header
    echo
    echo "[temperature]"
    echo "throttling = ${TARGET_TEMP}"
    echo "throttling_recovery = $((TARGET_TEMP - 10))"
    echo
    echo "[[safe-points]]"
    echo "frequency = 350"
    echo "voltage = 700"
    echo
    echo "[[safe-points]]"
    echo "frequency = ${TARGET_FREQ}"
    echo "voltage = ${TARGET_VOLT}"
}

write_service_unit() {
    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Cyan Skillfish GPU Governor
After=multi-user.target

[Service]
Type=simple
ExecStart=${BIN_PATH} ${CONF_FILE}
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
}

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] mkdir -p $BIN_DIR"
    log "[DRY-RUN] cp $BIN_SRC $BIN_PATH"
    log "[DRY-RUN] cp $PERF_MODE_SRC $PERF_MODE_PATH"
    log "[DRY-RUN] cp $DBUS_POLICY_SRC $DBUS_POLICY_PATH"
    log "$(t m06_dry_write "$CONF_FILE")"
    render_governor_config
    log "[DRY-RUN] write_service_unit + systemctl daemon-reload && systemctl restart $SERVICE_NAME"
else
    mkdir -p "$BIN_DIR"
    cp "$BIN_SRC" "$BIN_PATH" && chmod +x "$BIN_PATH"
    log "$(t m06_bin_installed "$BIN_PATH")"

    cp "$PERF_MODE_SRC" "$PERF_MODE_PATH" && chmod +x "$PERF_MODE_PATH"
    log "$(t m06_perf_installed "$PERF_MODE_PATH")"

    cp "$DBUS_POLICY_SRC" "$DBUS_POLICY_PATH"
    log "$(t m06_dbus_installed "$DBUS_POLICY_PATH")"
    busctl --system call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus ReloadConfig 2>/dev/null || true

    render_governor_config > "$CONF_FILE"
    log "$(t m06_file_written "$CONF_FILE")"
    cat "$CONF_FILE"

    write_service_unit
    log "$(t m06_service_installed "$SERVICE_FILE")"
    systemctl daemon-reload
    systemctl restart "$SERVICE_NAME" 2>/dev/null || systemctl start "$SERVICE_NAME"
    sleep 2
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        log "$(t m06_started)"
        systemctl status "$SERVICE_NAME" --no-pager -n 0 | sed -n '1,4p'
    else
        warn "$(t m06_start_failed)"
        systemctl status "$SERVICE_NAME" --no-pager || true
        journalctl -u "$SERVICE_NAME" -n 20 --no-pager || true
    fi
fi

t m06_progression

if confirm "$(t m06_enable_boot_q)"; then
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] systemctl enable $SERVICE_NAME"
    else
        systemctl enable "$SERVICE_NAME" >/dev/null && log "$(t m06_enabled)"
    fi
fi
