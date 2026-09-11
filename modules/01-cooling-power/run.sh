#!/usr/bin/env bash
# Module 01 — Refroidissement & alimentation.
# Étapes PHYSIQUES : ce module n'exécute rien sur la carte, il affiche
# une checklist de validation avant de continuer vers les modules logiciels.
set -uo pipefail
BC250_ROOT="${BC250_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${BC250_ROOT}/lib/common.sh"

title "$(t m01_title)"

t m01_checklist

if confirm "$(t m01_confirm_q)"; then
    log "$(t m01_confirmed)"
    touch "${BC250_ROOT}/logs/.cooling_power_confirmed"
else
    warn "$(t m01_not_confirmed)"
fi
