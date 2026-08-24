#!/usr/bin/env bash
# Module 02 — BIOS/UEFI modifié (Forbidden-Darkness UEFI Menu Script).
#
# Cette étape ne peut PAS être 100% automatisée depuis Linux : le flash se
# fait depuis un shell UEFI après reboot sur une clé USB. Ce module prépare
# le terrain (vérifie la clé, copie les fichiers) et délègue le reste à
# l'outil officiel vendorisé, qui gère lui-même le reboot en shell UEFI.
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "02 - BIOS/UEFI modifié (8 cœurs intégrés + VRAM 512Mo)"
require_root

UEFI_DIR="${BC250_ROOT}/vendor/bc250-uefi-menu"

cat <<'EOF'
Cette étape flashe un BIOS modifié (Forbidden-Darkness UEFI Menu Script)
qui :
  - intègre le déblocage des 8 cœurs CPU directement dans un menu BIOS
    (persistant, pas besoin de relancer un script à chaque cold boot)
  - permet de changer l'allocation VRAM de 8 Go (défaut) à 512 Mo,
    nécessaire pour l'allocation dynamique RAM/VRAM en jeu

Procédure (résumé — suivez la vidéo officielle du projet pour le détail
visuel, lien dans docs/guide_old_lamer.md section 4) :

  1. Une clé USB formatée est nécessaire.
  2. Ce script copie reboot-uefi.sh + l'archive Firmware.7z sur la clé.
  3. Vous lancerez reboot-uefi.sh avec l'option 4 (extraire le .7z sur la
     clé), puis l'option 2 (reboot one-time sur la clé via efibootmgr).
  4. Une fois dans le shell UEFI : fs1: -> lancer l'outil de flash fourni
     dans l'archive -> sauvegarder l'ancien BIOS (préfixe -O) -> flasher
     le nouveau (-P -N).
  5. Clear CMOS (jumper ou retrait pile 20-30s).
  6. Dans le nouveau BIOS : activer "Unlock CPU cores" et remettre la
     VRAM à 512 Mo (valeur définie dans config: BIOS_TARGET_VRAM_MB).

⚠️  Un mauvais flash de BIOS peut rendre la carte inutilisable. Suivez la
    procédure à la lettre et gardez la sauvegarde de l'ancien BIOS.
EOF

echo
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS,LABEL | grep -E 'sd|nvme|mmcblk' || warn "Aucun périphérique amovible détecté."
echo

usb_mount=""
if [[ "${BC250_YES:-0}" == "1" ]]; then
    warn "BC250_YES=1 : le flash BIOS est une étape physique (reboot en shell UEFI + manipulation"
    warn "manuelle) qui ne peut pas être rendue non-interactive. Étape de copie sur clé USB ignorée."
else
    read -rp "Point de montage de la clé USB cible (ex: /run/media/\$USER/USBSTICK), vide pour ignorer : " usb_mount
fi

if [[ -n "${usb_mount}" && -d "${usb_mount}" ]]; then
    log "Copie de reboot-uefi.sh et Firmware.7z vers ${usb_mount} ..."
    cp -v "${UEFI_DIR}/reboot-uefi.sh" "${usb_mount}/"
    cp -v "${UEFI_DIR}/Firmware/Firmware.7z" "${usb_mount}/"
    chmod +x "${usb_mount}/reboot-uefi.sh"
    log "Fichiers copiés. Lancez ensuite, DEPUIS LA CLÉ USB :"
    echo "    cd ${usb_mount} && sudo bash reboot-uefi.sh"
else
    warn "Copie ignorée. Vous pouvez lancer manuellement :"
    echo "    sudo bash '${UEFI_DIR}/reboot-uefi.sh'"
fi

echo
if [[ "${BC250_YES:-0}" == "1" ]]; then
    warn "BC250_YES=1 : reboot-uefi.sh est un outil interactif (menu, prompts) — non lancé automatiquement."
    warn "Lancez-le vous-même : sudo bash '${UEFI_DIR}/reboot-uefi.sh'"
elif confirm "Lancer maintenant l'outil interactif reboot-uefi.sh (menu options 4 puis 2) ?"; then
    bash "${UEFI_DIR}/reboot-uefi.sh"
fi

warn "Rappel : après le flash + clear CMOS, entrez dans le BIOS pour activer"
warn "\"Unlock CPU cores\" et régler la VRAM à ${BIOS_TARGET_VRAM_MB:-512} Mo avant de continuer."

if confirm "Le flash BIOS est-il terminé et l'option 'Unlock CPU cores' activée dans le BIOS ?"; then
    touch "${BC250_ROOT}/logs/bios_flashed.flag"
    log "Flag bios_flashed.flag créé — le module 03 détectera le BIOS modifié."
else
    warn "Flag non créé. Le module 03 tentera l'unlock logiciel (volatile)."
fi
