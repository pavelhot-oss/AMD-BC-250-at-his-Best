#!/usr/bin/env bash
# Module 00 — Preflight : vérifie matériel, distro et dépendances de base.
set -uo pipefail
BC250_ROOT="${BC250_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${BC250_ROOT}/lib/common.sh"

title "$(t m00_title)"

# Guide Old Lamer, étape 1 : confirmer boot de test (alim + clavier + DisplayPort) + BIOS
if [[ "${DRY_RUN:-0}" == "1" || "${BC250_YES:-0}" == "1" || "${BC250_FORCE:-0}" == "1" ]]; then
    log "$(t m00_dry_test_boot "$(t m00_q_test_boot)")"
else
    if ! confirm "$(t m00_q_test_boot)"; then
        warn "$(t m00_strongly_recommended)"
        if ! confirm "$(t common_continue_anyway_q)"; then
            die "$(t m00_abort_user)"
        fi
    fi
fi

require_bc250

DISTRO="$(detect_distro)"
log "$(t m00_distro_detected "$DISTRO")"

case "$DISTRO" in
    unknown)
        warn "$(t m00_distro_unknown)"
        ;;
esac

log "$(t m00_kernel "$(uname -r)")"
log "$(t m00_cpu "$(lscpu 2>/dev/null | awk -F: '/Model name/{print $2}' | xargs)")"

MISSING=()
for bin in git curl lspci python3; do
    command -v "$bin" &>/dev/null || MISSING+=("$bin")
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    warn "$(t m00_missing_tools "${MISSING[*]}")"
    if confirm "$(t m00_install_deps_q)"; then
        require_root
        case "$DISTRO" in
            bazzite-ostree|fedora-ostree) pkg_install git curl pciutils python3 ;;
            fedora)                       pkg_install git curl pciutils python3 ;;
            arch)                         pkg_install git curl pciutils python3 ;;
            debian)                       pkg_install git curl pciutils python3 ;;
        esac
    fi
else
    log "$(t m00_deps_ok)"
fi

maybe_prompt_reboot
log "$(t m00_done)"
