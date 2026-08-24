#!/usr/bin/env bash
# Module 04 — Déblocage des Compute Units GPU (jusqu'à 40 CU).
#
# Méthode privilégiée : bc250-cu-live-manager (vendor/), "on the fly",
# aucune recompilation de kernel nécessaire. Fonctionne sur Bazzite,
# Arch/CachyOS et Fedora.
#
# Une méthode alternative "kernel patché" (vendor/bc250-40cu-unlock) est
# disponible et documentée plus bas pour les cartes dont la harvest map
# n'est pas symétrique (nécessite alors du masquage sélectif de WGP).
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "04 - Déblocage des Compute Units GPU (CU)"
require_root
require_bc250

TOOL="${BC250_ROOT}/vendor/bc250-cu-live-manager/bc250-cu-live-manager.sh"
chmod +x "$TOOL"

if ! command -v umr &>/dev/null; then
    warn "umr introuvable, installation via l'outil intégré..."
    "$TOOL" install-umr
    DISTRO="$(detect_distro)"
    if [[ "$DISTRO" == "bazzite-ostree" || "$DISTRO" == "fedora-ostree" ]]; then
        warn "Système immuable (rpm-ostree) : un reboot est nécessaire avant de continuer."
        if confirm "Redémarrer maintenant ?"; then reboot; fi
        die "Relancez ce module après le reboot."
    fi
fi

log "État actuel de la table WGP :"
"$TOOL" status || true

case "${GPU_CU_MODE:-full}" in
    full)
        log "Mode config: FULL -> déblocage des 40 CU (20 WGP)."
        "$TOOL" --yes enable all
        ;;
    factory)
        log "Mode config: FACTORY -> restauration de la table d'origine (24 CU)."
        "$TOOL" --yes stock-dispatch
        ;;
    custom)
        log "Mode config: CUSTOM -> déblocage complet puis masquage des WGP listées."
        "$TOOL" --yes enable all
        if [[ -n "${GPU_CU_DISABLE_LIST:-}" ]]; then
            IFS=',' read -ra BAD_WGPS <<< "$GPU_CU_DISABLE_LIST"
            for wgp in "${BAD_WGPS[@]}"; do
                log "Désactivation de la WGP défectueuse : $wgp"
                "$TOOL" --yes disable-wgp "$wgp"
            done
        else
            warn "GPU_CU_MODE=custom mais GPU_CU_DISABLE_LIST est vide, rien à masquer."
        fi
        ;;
    *)
        die "GPU_CU_MODE inconnu dans la config : ${GPU_CU_MODE:-<vide>} (attendu: full|factory|custom)"
        ;;
esac

echo
log "Nouvelle table WGP :"
"$TOOL" status || true

echo
warn "Testez la stabilité maintenant (FurMark Vulkan + un jeu) AVANT de rendre ce réglage permanent."
if confirm "La configuration est stable, rendre permanent au boot (write-service-table + install-service) ?"; then
    "$TOOL" --yes write-service-table
    "$TOOL" --yes install-service
    log "Table sauvegardée et service de restauration au boot installé."
else
    warn "Réglage appliqué en LIVE uniquement : il sera perdu au prochain reboot."
fi

cat <<EOF

--------------------------------------------------------------------
Méthode alternative "kernel patché" (vendor/bc250-40cu-unlock) :
  utile si votre harvest map n'est PAS symétrique (paires désactivées
  dispersées au lieu d'être toutes du même côté). Voir :
    ${BC250_ROOT}/vendor/bc250-40cu-unlock/README.md
    ${BC250_ROOT}/vendor/bc250-40cu-unlock/scripts/cu_map.sh
    ${BC250_ROOT}/vendor/bc250-40cu-unlock/scripts/bc250-cu-health-test.sh
Ce module (live manager) reste la méthode recommandée en premier lieu.
--------------------------------------------------------------------
EOF
