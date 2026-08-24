#!/usr/bin/env bash
# Module 01 — Refroidissement & alimentation.
# Étapes PHYSIQUES : ce module n'exécute rien sur la carte, il affiche
# une checklist de validation avant de continuer vers les modules logiciels.
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "01 - Refroidissement & alimentation (étapes physiques)"

cat <<'EOF'
Ce module ne modifie rien sur la machine : le refroidissement et
l'alimentation sont des étapes matérielles qui doivent être faites
AVANT de pousser l'overclock logiciel (modules 05/06), sous peine de
crash, throttling voire dommage matériel.

Checklist (voir docs/guide_old_lamer.md section 2 & 3 pour le détail) :

  [ ] Refroidissement choisi et monté :
        - Watercooling AIO 240mm (meilleure option, <60°C en charge)
        - ou 1x ventilateur 120mm (ex: Arctic P12 Pro) sur heatsink
          partiellement ouvert (ne découper QUE la zone du ventilateur)
  [ ] Pâte thermique remplacée sur l'APU : PTM 7950 (gain 5-8°C)
  [ ] Thermal putty appliqué sur VRM + puces GDDR
  [ ] Heatsink passif collé sur le backplate (zone RAM/VRAM)
  [ ] Rondelles plastique ajoutées sous les vis à ressort du heatsink central
        (pression de contact PTM 7950).
  [ ] Si ventilateur d'occasion sans PWM : jamais sous 1800 RPM.
  [ ] Alimentation dimensionnée : au moins 25A sur le rail 12V
        (FSP500 / Meanwell 500W / Meanwell LOP-300-12 / PSU serveur
        Dell-HP recyclée avec brochage vérifié)
  [ ] Si carte débloquée à 40 CU + overclock poussé (>300W) :
        2x connecteurs Molex Microfit 3.0 (43025-0800) ajoutés en
        complément du connecteur PCIe d'origine, câbles AWG18 minimum

⚠️  Le connecteur PCIe unique d'origine peut FONDRE sous forte charge
    (40 CU débloqués + overclock). Ne poussez pas l'overclock GPU
    (module 06) sans cette étape si vous visez plus de ~250-300W.

EOF

if confirm "Confirmez-vous que le refroidissement et l'alimentation sont en place et validés ?"; then
    log "Étape physique validée par l'utilisateur. Vous pouvez continuer."
    touch "${BC250_ROOT}/logs/.cooling_power_confirmed"
else
    warn "Étape non confirmée. Il est fortement recommandé de la traiter avant de continuer vers l'overclock (modules 05/06)."
fi
