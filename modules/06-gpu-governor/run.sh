#!/usr/bin/env bash
# Module 06 — Overclock GPU via le gouverneur cyan-skillfish.
# Ce module gère le cycle de vie complet : clone, build Rust, et configuration.
set -uo pipefail
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
# Configuration (inchangé par rapport à l'original)
# ------------------------------------------------------------------
t m06_follow_readme "$REPO_DIR"

if ! confirm "$(t m06_installed_q)"; then
    warn "$(t m06_config_postponed)"
    exit 0
fi

CONF_DIR="/etc/cyan-skillfish-governor"
CONF_FILE="${CONF_DIR}/config.toml"

TARGET_FREQ="${GPU_FREQ_MHZ:-2000}"
TARGET_TEMP="${GPU_TEMP_TARGET_C:-85}"
TARGET_VOLT="${GPU_VOLT_MV:-}"

log "$(t m06_generating "$CONF_FILE" "$TARGET_TEMP")"

# Contenu du config.toml (commentaires dans la langue active)
render_governor_config() {
    t m06_toml_header
    echo
    echo "target-temperature = ${TARGET_TEMP}"
    echo
    echo "[[safe-points]]"
    echo "frequency = 350"
    echo "voltage = 700"
    echo
    echo "[[safe-points]]"
    echo "frequency = ${TARGET_FREQ}"
    if [[ -n "$TARGET_VOLT" ]]; then
        echo "voltage = ${TARGET_VOLT}"
    else
        t m06_toml_no_volt
    fi
}

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] mkdir -p $CONF_DIR"
    log "$(t m06_dry_write "$CONF_FILE")"
    render_governor_config
else
    mkdir -p "$CONF_DIR"
    render_governor_config > "$CONF_FILE"
    log "$(t m06_file_written "$CONF_FILE")"
    cat "$CONF_FILE"
fi

t m06_progression

if confirm "$(t m06_restart_q)"; then
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] systemctl restart cyan-skillfish-governor-smu"
    else
        systemctl restart cyan-skillfish-governor-smu 2>/dev/null \
            || warn "$(t m06_service_name_hint)"
    fi
fi

warn "$(t m06_enable_yourself)"
echo "    sudo systemctl enable --now cyan-skillfish-governor-smu"

log "$(t m06_upstream_service)"
log "$(t m06_see_readme "$REPO_DIR")"
