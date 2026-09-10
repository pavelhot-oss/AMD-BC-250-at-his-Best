#!/usr/bin/env bash
# Module 05 — Overclock / undervolt CPU (bc250_smu_oc, vendorisé).
#
# ⚠️  Ne JAMAIS dépasser 1300 mV de Vid CPU. Un overclock de fréquence sans
#     undervolt correspondant peut détruire le CPU (Vid non plafonné).
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "$(t m05_title)"
require_root
require_bc250

if [[ -f "${BC250_ROOT}/logs/.cooling_power_confirmed" ]]; then
    :
else
    warn "$(t common_m01_not_confirmed)"
    confirm "$(t common_continue_anyway_q)" || exit 1
fi

TARGET_FREQ="${CPU_FREQ_MHZ:-3850}"
TARGET_VID="${CPU_VID_MV:-1150}"
TEMP_LIMIT="${CPU_TEMP_LIMIT_C:-90}"
STRESS_SEC="${CPU_STRESS_SECONDS:-300}"

if (( TARGET_VID > 1300 )); then
    die "$(t m05_vid_over_limit "$TARGET_VID")"
fi

DISTRO="$(detect_distro)"

log "$(t m05_install_stress)"
case "$DISTRO" in
    bazzite-ostree|fedora-ostree) pkg_install stress-ng stress ;;
    fedora)                       pkg_install stress-ng stress ;;
    arch)                         pkg_install stress-ng stress ;;
    debian)                       pkg_install stress-ng stress ;;
esac
maybe_prompt_reboot

log "$(t m05_install_smu_oc)"
VENDOR_DIR="${BC250_ROOT}/vendor/bc250_smu_oc"
if command -v pipx &>/dev/null; then
    pipx install --force "${VENDOR_DIR}" || pip install --break-system-packages --force-reinstall "${VENDOR_DIR}"
else
    pip install --break-system-packages --force-reinstall "${VENDOR_DIR}"
fi

# Retour aux valeurs stock via l'API Python vendorisée (3500 MHz, courbe
# Vid d'origine, limites de température 100°C). Utilisé si le stress test
# échoue ou si l'utilisateur refuse de rendre le réglage permanent.
revert_to_stock() {
    python3 -c "
import sys
sys.path.insert(0, '${VENDOR_DIR}')
from bc250_smu import Bc250Smu
smu = Bc250Smu(use_flock=True)
smu.q3_0x8f_set_max_cpu_boost_clk(3500)
smu.q3_0x50_scale_f_vid_curve(0)
smu.disable_extra_cpu_gpu_voltage(False)
smu.q3_0x8b_set_cpu_max_temperature(100)
smu.q3_0x8c_set_gpu_max_temperature(100)
print('$(t m05_reverted)')
"
}

WORKDIR="${BC250_ROOT}/logs/cpu-oc"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

confirm "$(t m05_apply_q "$TARGET_FREQ" "$TARGET_VID")" || exit 1

log "$(t m05_applying "$TARGET_FREQ" "$TARGET_VID" "$TEMP_LIMIT")"
if ! bc250-detect --frequency "$TARGET_FREQ" --vid "$TARGET_VID" --temp "$TEMP_LIMIT" --keep -c overclock.conf; then
    warn "$(t m05_detect_failed)"
    revert_to_stock
    exit 1
fi

if [[ ! -s "${WORKDIR}/overclock.conf" ]]; then
    warn "$(t m05_config_missing)"
    revert_to_stock
    exit 1
fi

NPROC="$(nproc)"
if (( NPROC < 16 )); then
    warn "$(t m05_threads_warn_1 "$NPROC")"
    warn "$(t m05_threads_warn_2 "$NPROC")"
fi
log "$(t m05_stress_start "$STRESS_SEC" "$NPROC" "$STRESS_SEC")"
if ! stress-ng --cpu "${NPROC}" --timeout "${STRESS_SEC}s"; then
    warn "$(t m05_stress_failed)"
    revert_to_stock
    exit 1
fi

echo
if confirm "$(t m05_stable_q)"; then
    if ! bc250-apply --install "${WORKDIR}/overclock.conf"; then
        warn "$(t m05_apply_install_failed)"
        exit 1
    fi
    if [[ ! -f /etc/systemd/system/bc250-smu-oc.service ]]; then
        warn "$(t m05_service_missing)"
        exit 1
    fi
    systemctl daemon-reload
    if ! systemctl enable --now bc250-smu-oc; then
        warn "$(t m05_service_enable_failed)"
        exit 1
    fi
    log "$(t m05_service_enabled "$TARGET_FREQ" "$TARGET_VID")"
else
    warn "$(t m05_not_permanent)"
    revert_to_stock
    exit 1
fi

t m05_monitoring_tip

maybe_prompt_reboot
