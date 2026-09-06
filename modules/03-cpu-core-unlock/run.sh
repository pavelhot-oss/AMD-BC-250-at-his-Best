#!/usr/bin/env bash
# Module 03 — Déblocage des 2 cœurs CPU cachés (6c/12t -> 8c/16t).
#
# S'appuie sur vendor/bc250-core-unlock/bc250-unlock-cores.py.
# L'unlock est volatile : il survit à un warm reboot mais pas à un cold
# boot. On installe donc un service systemd oneshot qui le réapplique à
# CHAQUE démarrage (couvre les deux cas uniformément).
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "$(t m03_title)"
require_root
require_bc250

if [[ -f "${BC250_ROOT}/logs/bios_flashed.flag" ]]; then
    log "$(t m03_bios_detected_1)"
    log "$(t m03_bios_detected_2)"
    exit 0
fi

TOOL="${BC250_ROOT}/vendor/bc250-core-unlock/bc250-unlock-cores.py"
chmod +x "$TOOL"

apply_unlock() {
    local force_flag=()
    [[ "${CPU_UNLOCK_FORCE_NON_STANDARD_MASK:-0}" == "1" ]] && force_flag=(-f)

    if systemctl is-active --quiet cyan-skillfish-governor-smu 2>/dev/null; then
        log "$(t m03_stop_governor)"
        systemctl stop cyan-skillfish-governor-smu
        RESTART_GOVERNOR=1
    else
        RESTART_GOVERNOR=0
    fi

    "$TOOL" "${force_flag[@]}"
    local rc=$?

    if [[ "$RESTART_GOVERNOR" == "1" ]]; then
        systemctl start cyan-skillfish-governor-smu || true
    fi
    return $rc
}

if [[ "${CPU_UNLOCK_8_CORES:-1}" != "1" ]]; then
    warn "$(t m03_disabled_in_config)"
    exit 0
fi

log "$(t m03_attempt)"
if apply_unlock; then
    log "$(t m03_mask_written)"
else
    err "$(t m03_unlock_failed_1)"
    err "$(t m03_unlock_failed_2)"
    exit 1
fi

if confirm "$(t m03_install_service_q)"; then
    # Même condition stricte que apply_unlock() : ${VAR:+-f} se déclencherait
    # à tort dès que la variable est définie (même à "0"), ce qui forcerait
    # -f à chaque boot sur la config par défaut (CPU_UNLOCK_FORCE_NON_STANDARD_MASK=0
    # explicitement défini dans bc250-beast.conf.example). Cf audit du 24/08/2026.
    SERVICE_FORCE_FLAG=""
    [[ "${CPU_UNLOCK_FORCE_NON_STANDARD_MASK:-0}" == "1" ]] && SERVICE_FORCE_FLAG="-f"

    cat > /etc/systemd/system/bc250-core-unlock.service <<EOF
[Unit]
Description=BC-250: unlock 2 hidden CPU cores (6c/12t -> 8c/16t)
After=multi-user.target
Before=display-manager.service

[Service]
Type=oneshot
ExecStart=/usr/bin/env bash -c 'systemctl is-active --quiet cyan-skillfish-governor-smu && systemctl stop cyan-skillfish-governor-smu; ${TOOL} ${SERVICE_FORCE_FLAG}; systemctl start cyan-skillfish-governor-smu 2>/dev/null || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable bc250-core-unlock.service
    log "$(t m03_service_installed)"
    warn "$(t m03_takes_effect_after_reboot)"
else
    warn "$(t m03_no_persistence)"
fi

if confirm "$(t m03_reboot_q)"; then
    reboot
fi
