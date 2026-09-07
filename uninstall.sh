#!/usr/bin/env bash
# uninstall.sh — Retire les changements PERSISTANTS installés par bc250-beast.
# Ne touche pas au BIOS flashé (module 02, à refaire manuellement si besoin)
# ni au refroidissement/câblage (physique).
#
# Usage : sudo ./uninstall.sh [--lang en|fr]
set -uo pipefail

export BC250_ROOT
BC250_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${BC250_ROOT}/lib/common.sh"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --lang)
            [[ -n "${2:-}" ]] || die "$(t inst_lang_needs_arg "$(i18n_supported)")"
            i18n_set "$2" || die "$(t i18n_invalid "$2" "$(i18n_supported)")"
            shift ;;
        --lang=*)
            i18n_set "${1#--lang=}" || die "$(t i18n_invalid "${1#--lang=}" "$(i18n_supported)")" ;;
        -h|--help) t uninst_usage; exit 0 ;;
        *)         die "$(t inst_unknown_arg "$1")" ;;
    esac
    shift
done

# Charge la config existante (si présente) pour que le nettoyage des kargs
# zswap utilise les VRAIES valeurs appliquées, pas les valeurs par défaut du
# script. On ne passe pas par load_config() ici : on ne veut pas recréer un
# fichier de config au moment de désinstaller si l'utilisateur l'a supprimé.
if [[ -f "${BC250_ROOT}/config/bc250-beast.conf" ]]; then
    # shellcheck disable=SC1091
    source "${BC250_ROOT}/config/bc250-beast.conf"
    if [[ "$I18N_EXPLICIT" == "0" && -n "${UI_LANG:-}" ]]; then
        i18n_load "$UI_LANG" || warn "$(t i18n_invalid "$UI_LANG" "$(i18n_supported)")"
    fi
fi

require_root
title "$(t uninst_title)"

# CPU core unlock service
if systemctl list-unit-files | grep -q bc250-core-unlock.service; then
    log "$(t uninst_rm_core_unlock)"
    systemctl disable --now bc250-core-unlock.service 2>/dev/null || true
    rm -f /etc/systemd/system/bc250-core-unlock.service
fi

# CPU SMU overclock service
if systemctl list-unit-files | grep -q bc250-smu-oc.service; then
    log "$(t uninst_disable_smu_oc)"
    systemctl disable --now bc250-smu-oc.service 2>/dev/null || true
fi

# GPU CU live manager boot service
LIVE_TOOL="${BC250_ROOT}/vendor/bc250-cu-live-manager/bc250-cu-live-manager.sh"
if [[ -x "$LIVE_TOOL" ]]; then
    log "$(t uninst_gpu_stock)"
    "$LIVE_TOOL" --yes stock-dispatch 2>/dev/null || true
    "$LIVE_TOOL" --yes uninstall-service 2>/dev/null || true
fi

# 40cu kernel patch (si la méthode alternative avait été utilisée)
CONF40="/etc/modprobe.d/bc250-40cu.conf"
[[ -f "$CONF40" ]] && { log "$(t uninst_rm_file "$CONF40")"; rm -f "$CONF40"; }
CONFMASK="/etc/modprobe.d/bc250-40cu-selective-mask.conf"
[[ -f "$CONFMASK" ]] && { log "$(t uninst_rm_file "$CONFMASK")"; rm -f "$CONFMASK"; }

# Mitigations / zswap (rpm-ostree uniquement, retire les kargs ajoutés)
if command -v rpm-ostree &>/dev/null; then
    log "$(t uninst_kargs)"
    rpm-ostree kargs \
        --delete-if-present=mitigations=off \
        --delete-if-present=zswap.enabled=1 \
        --delete-if-present=zswap.max_pool_percent="${ZSWAP_MAX_POOL_PERCENT:-25}" \
        --delete-if-present=zswap.compressor="${ZSWAP_COMPRESSOR:-lz4}" \
        --delete-if-present=systemd.zram=0 2>/dev/null || true
    warn "$(t uninst_kargs_reboot)"
fi

warn "$(t uninst_swap_kept_1)"
warn "$(t uninst_swap_kept_2)"
echo "    sudo swapoff /var/swap/swapfile"
echo "    sudo sed -i '\\|/var/swap/swapfile|d' /etc/fstab"
echo "    sudo rm -rf /var/swap"

log "$(t uninst_done_1)"
log "$(t uninst_done_2)"
