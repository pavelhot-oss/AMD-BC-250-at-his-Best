#!/usr/bin/env bash
# Module 05 — Overclock / undervolt CPU (bc250_smu_oc, vendorisé).
#
# ⚠️  Ne JAMAIS dépasser 1300 mV de Vid CPU. Un overclock de fréquence sans
#     undervolt correspondant peut détruire le CPU (Vid non plafonné).
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "05 - Overclock / undervolt CPU"
require_root
require_bc250

if [[ -f "${BC250_ROOT}/logs/.cooling_power_confirmed" ]]; then
    :
else
    warn "Le module 01 (refroidissement/alimentation) n'a pas été confirmé."
    confirm "Continuer quand même ?" || exit 1
fi

TARGET_FREQ="${CPU_FREQ_MHZ:-3850}"
TARGET_VID="${CPU_VID_MV:-1150}"
TEMP_LIMIT="${CPU_TEMP_LIMIT_C:-90}"
STRESS_SEC="${CPU_STRESS_SECONDS:-300}"

if (( TARGET_VID > 1300 )); then
    die "CPU_VID_MV=${TARGET_VID} dépasse la limite absolue de sécurité de 1300 mV. Corrigez config/bc250-beast.conf."
fi

DISTRO="$(detect_distro)"

log "Installation de l'outil de stress-test 'stress-ng'..."
case "$DISTRO" in
    bazzite-ostree|fedora-ostree) pkg_install stress-ng ;;
    fedora)                       pkg_install stress-ng ;;
    arch)                         pkg_install stress-ng ;;
    debian)                       pkg_install stress-ng ;;
esac
maybe_prompt_reboot

log "Installation de bc250-smu-oc depuis la copie vendorisée..."
VENDOR_DIR="${BC250_ROOT}/vendor/bc250_smu_oc"
if command -v pipx &>/dev/null; then
    pipx install --force "${VENDOR_DIR}" || pip install --break-system-packages --force-reinstall "${VENDOR_DIR}"
else
    pip install --break-system-packages --force-reinstall "${VENDOR_DIR}"
fi

WORKDIR="${BC250_ROOT}/logs/cpu-oc"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

confirm "Appliquer ${TARGET_FREQ} MHz @ ${TARGET_VID} mV maintenant ?" || exit 1

log "Application de l'OC AVEC persistance (--keep) : ${TARGET_FREQ} MHz @ ${TARGET_VID} mV (limite temp ${TEMP_LIMIT}°C)"
bc250-detect --frequency "$TARGET_FREQ" --vid "$TARGET_VID" --temp "$TEMP_LIMIT" --keep -c overclock.conf

NPROC="$(nproc)"
if (( NPROC < 16 )); then
    warn "${NPROC} threads visibles (attendu 16 après unlock 8 cœurs) — avez-vous"
    warn "redémarré depuis le module 03 ? Le stress test va quand même utiliser ${NPROC} threads."
fi
log "Stress test CPU pendant ${STRESS_SEC}s (stress-ng --cpu ${NPROC} --timeout ${STRESS_SEC}s)..."
if ! stress-ng --cpu "${NPROC}" --timeout "${STRESS_SEC}s"; then
    warn "Stress test échoué — retour au stock."
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
print('Revert au stock effectué.')
"
    exit 1
fi

echo
if confirm "Le système est resté stable, rendre ce réglage permanent au démarrage ?"; then
    bc250-apply --install "${WORKDIR}/overclock.conf"
    systemctl enable --now bc250-smu-oc
    log "Service bc250-smu-oc activé au démarrage avec ${TARGET_FREQ}MHz @ ${TARGET_VID}mV."
else
    warn "Réglage non rendu permanent — retour au stock."
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
print('Revert au stock effectué.')
"
    exit 1
fi

cat <<EOF

Astuce monitoring :
  - amdgpu_top (métriques SMU en direct)
  - watch -n 1 "cat /proc/cpuinfo | grep MHz"   (détecter le clock stretching)
EOF

maybe_prompt_reboot