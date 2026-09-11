#!/usr/bin/env bash
# Module 02 — BIOS/UEFI modifié (Forbidden-Darkness UEFI Menu Script).
#
# Cette étape ne peut PAS être 100% automatisée depuis Linux : le flash se
# fait depuis un shell UEFI après reboot sur une clé USB. Ce module prépare
# la clé (fichiers bootables EFI + scripts + images ROM) et délègue le reste
# à l'outil officiel vendorisé, qui gère lui-même le reboot en shell UEFI.
#
# Notes d'audit :
#   - Firmware.7z ne contient QUE les images ROM (16 x 16 MiB). La clé doit
#     donc aussi recevoir EFI/BOOT/ (shell UEFI + AfuEfix64.efi) ainsi que
#     menu.nsh / startup.nsh, sinon elle n'est pas bootable.
#   - Les images sont construites sur la BIOS 3.00 : on vérifie la version.
#   - Un backup de la ROM courante ([menu 0f]) est fortement recommandé
#     avant le flash ([menu fr] pour restaurer).
set -uo pipefail
BC250_ROOT="${BC250_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${BC250_ROOT}/lib/common.sh"

title "$(t m02_title)"
require_root

UEFI_DIR="${BC250_ROOT}/vendor/bc250-uefi-menu"
ARCHIVE="${UEFI_DIR}/Firmware/Firmware.7z"

t m02_intro

# --- Compatibilité : les images sont basées sur la BIOS 3.00 ---
cur_bios="$(cat /sys/class/dmi/id/bios_version 2>/dev/null || echo unknown)"
if [[ "$cur_bios" == "P3.00" || "$cur_bios" == "3.00" ]]; then
    log "$(t m02_bios_check "$cur_bios")"
else
    warn "$(t m02_bios_check "$cur_bios")"
fi

echo
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS,LABEL | grep -E 'sd|nvme|mmcblk' || warn "$(t m02_no_removable)"
echo

usb_mount=""
if [[ "${BC250_YES:-0}" == "1" ]]; then
    warn "$(t m02_yes_mode_skip_1)"
    warn "$(t m02_yes_mode_skip_2)"
else
    read -rp "$(t m02_usb_prompt)" usb_mount
fi

prepare_usb() {
    local usb="$1" ex="" ok=0
    if [[ ! -w "$usb" ]]; then
        warn "$(t m02_copy_skipped)"
        echo "    sudo bash '${UEFI_DIR}/reboot-uefi.sh'"
        return 0
    fi
    log "$(t m02_copying "$usb")"
    cp -rv "${UEFI_DIR}/EFI" "$usb/"
    cp -v "${UEFI_DIR}/menu.nsh" "${UEFI_DIR}/startup.nsh" "${UEFI_DIR}/reboot-uefi.sh" "$usb/"
    mkdir -p "$usb/Firmware"

    # Décompresse les ROMs directement sur la clé : l'archive seule ne
    # contient QUE les images (le bootloader EFI/scripts sont déjà copiés
    # ci-dessus ; sans ça la clé n'est pas bootable). L'archive embarque un
    # dossier Firmware/ : on aplatit vers clé/Firmware/ comme attend par menu.nsh.
    local ex="" ok=0 tmp=""
    for c in 7z 7za bsdtar; do
        command -v "$c" &>/dev/null && { ex="$c"; break; }
    done
    if [[ -n "$ex" ]]; then
        tmp="$(mktemp -d)"
        case "$ex" in
            bsdtar) bsdtar -xf "$ARCHIVE" -C "$tmp" ;;
            *)      "$ex" x -y "-o$tmp" "$ARCHIVE" ;;
        esac
        mkdir -p "$usb/Firmware"
        if [[ -d "$tmp/Firmware" ]]; then
            cp -v "$tmp"/Firmware/* "$usb/Firmware/" && ok=1
        elif [[ -n "$(find "$tmp" -maxdepth 1 -type f 2>/dev/null | head -1)" ]]; then
            cp -v "$tmp"/* "$usb/Firmware/" && ok=1
        fi
        rm -rf "$tmp"
    fi
    if [[ "$ok" != "1" ]]; then
        cp -v "$ARCHIVE" "$usb/"
        warn "$(t m02_extract_note)"
    fi
    sync
    log "$(t m02_copied)"
    echo "    cd ${usb} && sudo bash reboot-uefi.sh"
}

if [[ -n "${usb_mount}" && -d "${usb_mount}" ]]; then
    prepare_usb "$usb_mount"
else
    warn "$(t m02_copy_skipped)"
    echo "    sudo bash '${UEFI_DIR}/reboot-uefi.sh'"
fi

echo
if [[ "${BC250_YES:-0}" == "1" ]]; then
    warn "$(t m02_yes_mode_tool_1)"
    warn "$(t m02_yes_mode_tool_2 "${UEFI_DIR}/reboot-uefi.sh")"
elif confirm "$(t m02_run_tool_q)"; then
    warn "$(t m02_backup_hint)"
    bash "${UEFI_DIR}/reboot-uefi.sh"
fi

warn "$(t m02_reminder_1)"
warn "$(t m02_reminder_2 "${BIOS_TARGET_VRAM_MB:-512}")"

# Le flag ne doit être créé QUE par une confirmation interactive réelle :
# en mode BC250_YES=1 rien n'est flasqué, on ne marque donc rien.
if [[ "${BC250_YES:-0}" == "1" ]]; then
    warn "$(t m02_flag_not_auto)"
elif confirm "$(t m02_flashed_q)"; then
    touch "${BC250_ROOT}/logs/bios_flashed.flag"
    log "$(t m02_flag_created)"
else
    warn "$(t m02_flag_not_created)"
fi