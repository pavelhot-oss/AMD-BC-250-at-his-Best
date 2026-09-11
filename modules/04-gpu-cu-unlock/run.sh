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
BC250_ROOT="${BC250_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${BC250_ROOT}/lib/common.sh"

title "$(t m04_title)"
require_root
require_bc250

TOOL="${BC250_ROOT}/vendor/bc250-cu-live-manager/bc250-cu-live-manager.sh"
chmod +x "$TOOL"

if ! command -v umr &>/dev/null; then
    warn "$(t m04_umr_missing)"
    "$TOOL" install-umr
    DISTRO="$(detect_distro)"
    if [[ "$DISTRO" == "bazzite-ostree" || "$DISTRO" == "fedora-ostree" ]]; then
        warn "$(t m04_immutable_reboot)"
        if confirm "$(t common_reboot_now_q)"; then reboot; fi
        die "$(t m04_rerun_after_reboot)"
    fi
fi

log "$(t m04_current_table)"
"$TOOL" status || true

case "${GPU_CU_MODE:-full}" in
    full)
        log "$(t m04_mode_full)"
        "$TOOL" --yes enable all
        ;;
    factory)
        log "$(t m04_mode_factory)"
        "$TOOL" --yes stock-dispatch
        ;;
    custom)
        log "$(t m04_mode_custom)"
        "$TOOL" --yes enable all
        if [[ -n "${GPU_CU_DISABLE_LIST:-}" ]]; then
            IFS=',' read -ra BAD_WGPS <<< "$GPU_CU_DISABLE_LIST"
            for wgp in "${BAD_WGPS[@]}"; do
                log "$(t m04_disable_wgp "$wgp")"
                "$TOOL" --yes disable-wgp "$wgp"
            done
        else
            warn "$(t m04_custom_empty)"
        fi
        ;;
    *)
        die "$(t m04_unknown_mode "${GPU_CU_MODE:-$(t common_empty)}")"
        ;;
esac

echo
log "$(t m04_new_table)"
"$TOOL" status || true

echo
warn "$(t m04_test_stability)"
if confirm "$(t m04_make_permanent_q)"; then
    "$TOOL" --yes write-service-table
    "$TOOL" --yes install-service
    log "$(t m04_permanent_done)"
else
    warn "$(t m04_live_only)"
fi

t m04_alt_method "$BC250_ROOT" "$BC250_ROOT" "$BC250_ROOT"
