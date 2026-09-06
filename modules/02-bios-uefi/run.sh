#!/usr/bin/env bash
# Module 02 — BIOS/UEFI modifié (Forbidden-Darkness UEFI Menu Script).
#
# Cette étape ne peut PAS être 100% automatisée depuis Linux : le flash se
# fait depuis un shell UEFI après reboot sur une clé USB. Ce module prépare
# le terrain (vérifie la clé, copie les fichiers) et délègue le reste à
# l'outil officiel vendorisé, qui gère lui-même le reboot en shell UEFI.
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "$(t m02_title)"
require_root

UEFI_DIR="${BC250_ROOT}/vendor/bc250-uefi-menu"

t m02_intro

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

if [[ -n "${usb_mount}" && -d "${usb_mount}" ]]; then
    log "$(t m02_copying "$usb_mount")"
    cp -v "${UEFI_DIR}/reboot-uefi.sh" "${usb_mount}/"
    cp -v "${UEFI_DIR}/Firmware/Firmware.7z" "${usb_mount}/"
    chmod +x "${usb_mount}/reboot-uefi.sh"
    log "$(t m02_copied)"
    echo "    cd ${usb_mount} && sudo bash reboot-uefi.sh"
else
    warn "$(t m02_copy_skipped)"
    echo "    sudo bash '${UEFI_DIR}/reboot-uefi.sh'"
fi

echo
if [[ "${BC250_YES:-0}" == "1" ]]; then
    warn "$(t m02_yes_mode_tool_1)"
    warn "$(t m02_yes_mode_tool_2 "${UEFI_DIR}/reboot-uefi.sh")"
elif confirm "$(t m02_run_tool_q)"; then
    bash "${UEFI_DIR}/reboot-uefi.sh"
fi

warn "$(t m02_reminder_1)"
warn "$(t m02_reminder_2 "${BIOS_TARGET_VRAM_MB:-512}")"

if confirm "$(t m02_flashed_q)"; then
    touch "${BC250_ROOT}/logs/bios_flashed.flag"
    log "$(t m02_flag_created)"
else
    warn "$(t m02_flag_not_created)"
fi
