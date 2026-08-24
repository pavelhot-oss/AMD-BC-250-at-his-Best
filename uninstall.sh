#!/usr/bin/env bash
# uninstall.sh — Retire les changements PERSISTANTS installés par bc250-beast.
# Ne touche pas au BIOS flashé (module 02, à refaire manuellement si besoin)
# ni au refroidissement/câblage (physique).
set -uo pipefail

export BC250_ROOT
BC250_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${BC250_ROOT}/lib/common.sh"

# Charge la config existante (si présente) pour que le nettoyage des kargs
# zswap utilise les VRAIES valeurs appliquées, pas les valeurs par défaut du
# script. On ne passe pas par load_config() ici : on ne veut pas recréer un
# fichier de config au moment de désinstaller si l'utilisateur l'a supprimé.
if [[ -f "${BC250_ROOT}/config/bc250-beast.conf" ]]; then
    # shellcheck disable=SC1091
    source "${BC250_ROOT}/config/bc250-beast.conf"
fi

require_root
title "Désinstallation des changements persistants bc250-beast"

# CPU core unlock service
if systemctl list-unit-files | grep -q bc250-core-unlock.service; then
    log "Suppression du service bc250-core-unlock..."
    systemctl disable --now bc250-core-unlock.service 2>/dev/null || true
    rm -f /etc/systemd/system/bc250-core-unlock.service
fi

# CPU SMU overclock service
if systemctl list-unit-files | grep -q bc250-smu-oc.service; then
    log "Désactivation du service bc250-smu-oc (réglage OC CPU)..."
    systemctl disable --now bc250-smu-oc.service 2>/dev/null || true
fi

# GPU CU live manager boot service
LIVE_TOOL="${BC250_ROOT}/vendor/bc250-cu-live-manager/bc250-cu-live-manager.sh"
if [[ -x "$LIVE_TOOL" ]]; then
    log "Retour à la table WGP d'origine (24 CU) et retrait du service de boot..."
    "$LIVE_TOOL" --yes stock-dispatch 2>/dev/null || true
    "$LIVE_TOOL" --yes uninstall-service 2>/dev/null || true
fi

# 40cu kernel patch (si la méthode alternative avait été utilisée)
CONF40="/etc/modprobe.d/bc250-40cu.conf"
[[ -f "$CONF40" ]] && { log "Suppression de $CONF40"; rm -f "$CONF40"; }
CONFMASK="/etc/modprobe.d/bc250-40cu-selective-mask.conf"
[[ -f "$CONFMASK" ]] && { log "Suppression de $CONFMASK"; rm -f "$CONFMASK"; }

# Mitigations / zswap (rpm-ostree uniquement, retire les kargs ajoutés)
if command -v rpm-ostree &>/dev/null; then
    log "Retrait des kernel args ajoutés (zswap, mitigations)..."
    rpm-ostree kargs \
        --delete-if-present=mitigations=off \
        --delete-if-present=zswap.enabled=1 \
        --delete-if-present=zswap.max_pool_percent="${ZSWAP_MAX_POOL_PERCENT:-25}" \
        --delete-if-present=zswap.compressor="${ZSWAP_COMPRESSOR:-lz4}" \
        --delete-if-present=systemd.zram=0 2>/dev/null || true
    warn "Un reboot est nécessaire pour appliquer le retrait des kernel args."
fi

warn "Le swapfile Btrfs (/var/swap) et sa ligne fstab n'ont PAS été supprimés"
warn "automatiquement (destructif). Supprimez-les manuellement si souhaité :"
echo "    sudo swapoff /var/swap/swapfile"
echo "    sudo sed -i '\\|/var/swap/swapfile|d' /etc/fstab"
echo "    sudo rm -rf /var/swap"

log "Désinstallation terminée. Le BIOS flashé (module 02) et le câblage"
log "(module 01) restent en place — ce sont des changements matériels."
