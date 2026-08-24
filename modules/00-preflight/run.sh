#!/usr/bin/env bash
# Module 00 — Preflight : vérifie matériel, distro et dépendances de base.
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "00 - Vérifications préalables"

# Guide Old Lamer, étape 1 : confirmer boot de test (alim + clavier + DisplayPort) + BIOS
if [[ "${DRY_RUN:-0}" == "1" || "${BC250_YES:-0}" == "1" || "${BC250_FORCE:-0}" == "1" ]]; then
    log "[DRY-RUN] Question boot de test : avez-vous effectué un boot de test (alim + clavier + DisplayPort) et confirmé l'accès au BIOS avant de continuer ?"
else
    if ! confirm "Avez-vous effectué un boot de test (alim + clavier + DisplayPort) et confirmé l'accès au BIOS avant de continuer ?"; then
        warn "Fortement recommandé avant toute modification."
        if ! confirm "Continuer quand même ?"; then
            die "Arrêt sur demande utilisateur. Effectuez le boot de test puis relancez."
        fi
    fi
fi

require_bc250

DISTRO="$(detect_distro)"
log "Distribution détectée : $DISTRO"

case "$DISTRO" in
    unknown)
        warn "Distribution non reconnue automatiquement. Les modules pourront échouer sur les étapes d'installation de paquets."
        ;;
esac

log "Noyau : $(uname -r)"
log "CPU  : $(lscpu 2>/dev/null | awk -F: '/Model name/{print $2}' | xargs)"

MISSING=()
for bin in git curl lspci python3; do
    command -v "$bin" &>/dev/null || MISSING+=("$bin")
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    warn "Outils manquants : ${MISSING[*]}"
    if confirm "Installer les dépendances de base maintenant ?"; then
        require_root
        case "$DISTRO" in
            bazzite-ostree|fedora-ostree) pkg_install git curl pciutils python3 ;;
            fedora)                       pkg_install git curl pciutils python3 ;;
            arch)                         pkg_install git curl pciutils python3 ;;
            debian)                       pkg_install git curl pciutils python3 ;;
        esac
    fi
else
    log "Toutes les dépendances de base sont présentes."
fi

maybe_prompt_reboot
log "Preflight terminé."
