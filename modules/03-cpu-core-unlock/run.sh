#!/usr/bin/env bash
# Module 03 — Déblocage des 2 cœurs CPU cachés (6c/12t -> 8c/16t).
#
# S'appuie sur vendor/bc250-core-unlock/bc250-unlock-cores.py.
# L'unlock est volatile : il survit à un warm reboot mais pas à un cold
# boot. On installe donc un service systemd oneshot qui le réapplique à
# CHAQUE démarrage (couvre les deux cas uniformément).
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "03 - Déblocage 8 cœurs CPU"
require_root
require_bc250

if [[ -f "${BC250_ROOT}/logs/bios_flashed.flag" ]]; then
    log "BIOS modifié détecté. L'unlock 8 cœurs est géré nativement par le BIOS."
    log "Pensez à vérifier que l'option 'Unlock CPU cores' est activée dans le menu BIOS."
    exit 0
fi

TOOL="${BC250_ROOT}/vendor/bc250-core-unlock/bc250-unlock-cores.py"
chmod +x "$TOOL"

apply_unlock() {
    local force_flag=()
    [[ "${CPU_UNLOCK_FORCE_NON_STANDARD_MASK:-0}" == "1" ]] && force_flag=(-f)

    if systemctl is-active --quiet cyan-skillfish-governor-smu 2>/dev/null; then
        log "Arrêt temporaire de cyan-skillfish-governor-smu (requis pour l'écriture SMU)..."
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
    warn "CPU_UNLOCK_8_CORES=0 dans la config, module ignoré."
    exit 0
fi

log "Tentative de déblocage des cœurs CPU..."
if apply_unlock; then
    log "Masque de présence CPU écrit avec succès."
else
    err "Échec du déblocage. Voir la sortie ci-dessus. Un masque non-standard (≠0x77)"
    err "suggère un vrai défaut silicium : relire modules/03-cpu-core-unlock avant de forcer."
    exit 1
fi

if confirm "Installer le service systemd de persistance (réappliqué à chaque boot) ?"; then
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
    log "Service bc250-core-unlock.service installé et activé."
    warn "Le déblocage prend effet APRÈS un reboot (l'écriture SMU n'active les cœurs qu'au prochain boot)."
else
    warn "Persistance non installée : relancez ce module après chaque coupure totale d'alimentation."
fi

if confirm "Redémarrer maintenant pour activer les 8 cœurs ?"; then
    reboot
fi
