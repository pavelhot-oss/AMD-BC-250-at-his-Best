#!/usr/bin/env bash
# Module 07 — Réglages système : zswap (anti-crash RAM/VRAM), mitigations
# CPU désactivées, MangoHud pour le monitoring en jeu.
set -uo pipefail
BC250_ROOT="${BC250_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${BC250_ROOT}/lib/common.sh"

title "$(t m07_title)"
require_root

DISTRO="$(detect_distro)"

# --------------------------------------------------------------
# zswap + swapfile Btrfs 32Go (procédure Bazzite/rpm-ostree exacte,
# issue de la description officielle de la vidéo Part XIV)
# --------------------------------------------------------------
setup_zswap_ostree() {
    log "$(t m07_zswap_ostree)"
    # Sur ostree : on n'utilise JAMAIS /etc/default/grub, tout passe par rpm-ostree kargs
    local zswap_args=(
        "zswap.enabled=1"
        "zswap.max_pool_percent=${ZSWAP_MAX_POOL_PERCENT:-25}"
        "zswap.compressor=${ZSWAP_COMPRESSOR:-lz4}"
        "systemd.zram=0"
    )
    local mitigation_args=("mitigations=off")

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] rpm-ostree kargs --append-if-missing ${zswap_args[*]}"
        log "[DRY-RUN] rpm-ostree kargs --append-if-missing ${mitigation_args[*]}"
        log "[DRY-RUN] rpm-ostree initramfs --enable --arg=--add-drivers --arg=${ZSWAP_COMPRESSOR:-lz4}"
        flag_reboot_needed
        warn "$(t m07_dry_reboot)"
        return 0
    fi

    rpm-ostree kargs --append-if-missing "${zswap_args[@]}"
    rpm-ostree kargs --append-if-missing "${mitigation_args[@]}"
    rpm-ostree initramfs --enable --arg=--add-drivers --arg="${ZSWAP_COMPRESSOR:-lz4}"
    flag_reboot_needed
    warn "$(t m07_ostree_reboot)"
    warn "$(t m07_rerun_after_reboot)"
}

setup_swapfile_btrfs() {
    local size="${SWAPFILE_SIZE_GB:-32}"
    if ! findmnt -no FSTYPE /var &>/dev/null || [[ "$(findmnt -no FSTYPE /var)" != "btrfs" ]]; then
        warn "$(t m07_var_not_btrfs_1)"
        warn "$(t m07_var_not_btrfs_2)"
        warn "$(t m07_var_not_btrfs_3)"
        return 0
    fi

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] swapoff -a"
        log "$(t m07_dry_rm_swap)"
        log "[DRY-RUN] btrfs subvolume create /var/swap"
        if command -v semanage &>/dev/null; then
            log "[DRY-RUN] semanage fcontext -a -t var_t '/var/swap(/.*)?'"
            log "[DRY-RUN] restorecon -Rv /var/swap"
        else
            log "$(t m07_dry_semanage_install)"
        fi
        log "[DRY-RUN] btrfs filesystem mkswapfile --size ${size}G /var/swap/swapfile"
        log "[DRY-RUN] semanage fcontext -a -t swapfile_t '/var/swap/swapfile'"
        log "[DRY-RUN] restorecon -v /var/swap/swapfile"
        log "[DRY-RUN] sed -i '\\|/var/swap/swapfile|d' /etc/fstab"
        log "[DRY-RUN] echo '/var/swap/swapfile none swap defaults,nofail 0 0' >> /etc/fstab"
        log "[DRY-RUN] swapon -a"
        local swappiness="${SWAPPINESS:-120}"
        log "[DRY-RUN] echo 'vm.swappiness=${swappiness}' > /etc/sysctl.d/99-swappiness.conf"
        log "[DRY-RUN] sysctl -p /etc/sysctl.d/99-swappiness.conf"
        log "$(t m07_dry_final_check)"
        return 0
    fi

    log "$(t m07_swapoff)"
    swapoff -a || true

    if [[ -d /var/swap ]]; then
        log "$(t m07_rm_old_swap)"
        rm -rf /var/swap
    fi

    log "$(t m07_create_subvol)"
    btrfs subvolume create /var/swap

    if command -v semanage &>/dev/null; then
        log "$(t m07_selinux_fix)"
        semanage fcontext -a -t var_t "/var/swap(/.*)?"
        restorecon -Rv /var/swap
    else
        warn "$(t m07_semanage_missing)"
        rpm-ostree install --idempotent policycoreutils-python-utils
        flag_reboot_needed
        warn "$(t m07_rerun_selinux)"
        return 0
    fi

    log "$(t m07_create_swapfile "$size")"
    btrfs filesystem mkswapfile --size "${size}G" /var/swap/swapfile
    semanage fcontext -a -t swapfile_t "/var/swap/swapfile"
    restorecon -v /var/swap/swapfile

    log "$(t m07_fstab)"
    sed -i '\|/var/swap/swapfile|d' /etc/fstab
    echo "/var/swap/swapfile none swap defaults,nofail 0 0" >> /etc/fstab

    log "$(t m07_swapon)"
    swapon -a
    swapon --show

    local swappiness="${SWAPPINESS:-120}"
    log "$(t m07_swappiness "$swappiness")"
    echo "vm.swappiness=${swappiness}" > /etc/sysctl.d/99-swappiness.conf
    sysctl -p /etc/sysctl.d/99-swappiness.conf

    log "$(t m07_final_check)"
    rpm-ostree kargs 2>/dev/null | grep -o 'zswap[^ ]*' || true
    cat /sys/module/zswap/parameters/enabled 2>/dev/null || warn "$(t m07_zswap_not_active)"
    cat /proc/sys/vm/swappiness
    swapon --show
}

# --------------------------------------------------------------
# MangoHud
# --------------------------------------------------------------
# Isolé dans une fonction : is_steamos doit rester local, ce qui exige
# d'être dans un scope de fonction (sinon `local` échoue silencieusement
# sous `set -u` et fait planter tout le module — cf audit du 24/08/2026).
install_mangohud() {
    title "$(t m07_mangohud_title)"

    # Détection steamos (Steam Deck / SteamOS) — MangoHud préinstallé
    local is_steamos=0
    if grep -qi 'steamos' /etc/os-release 2>/dev/null; then
        is_steamos=1
    fi

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        case "$DISTRO" in
            bazzite-ostree)
                log "$(t m07_dry_mangohud_bazzite)" ;;
            steamos|fedora-ostree|fedora)
                if [[ $is_steamos -eq 1 ]]; then
                    log "$(t m07_dry_mangohud_steamos)"
                else
                    log "[DRY-RUN] pkg_install mangohud"
                fi
                ;;
            arch)   log "[DRY-RUN] pkg_install mangohud" ;;
            debian) log "[DRY-RUN] pkg_install mangohud" ;;
        esac
        log "[DRY-RUN] $(t m07_mangohud_steam_hint)"
    else
        case "$DISTRO" in
            bazzite-ostree)
                log "$(t m07_mangohud_bazzite_check)"
                command -v mangohud &>/dev/null && log "$(t m07_mangohud_present)" || pkg_install mangohud ;;
            steamos|fedora-ostree|fedora)
                if [[ $is_steamos -eq 1 ]]; then
                    log "$(t m07_mangohud_steamos)"
                else
                    pkg_install mangohud
                fi
                ;;
            arch)   pkg_install mangohud ;;
            debian) pkg_install mangohud ;;
        esac
        log "$(t m07_mangohud_steam_hint)"
    fi
}

if [[ "${ENABLE_ZSWAP:-1}" == "1" ]]; then
    case "$DISTRO" in
        bazzite-ostree|fedora-ostree)
            if rpm-ostree kargs 2>/dev/null | grep -q 'zswap.enabled=1'; then
                log "$(t m07_zswap_already)"
                setup_swapfile_btrfs
            else
                setup_zswap_ostree
            fi
            ;;
        arch|fedora|debian)
            warn "$(t m07_zswap_other_distro_1)"
            warn "$(t m07_zswap_other_distro_2 "$DISTRO" "${ZSWAP_MAX_POOL_PERCENT:-25}" "${ZSWAP_COMPRESSOR:-lz4}")"
            warn "$(t m07_zswap_other_distro_3)"
            ;;
    esac
else
    warn "$(t m07_zswap_disabled)"
fi

# --------------------------------------------------------------
# Mitigations CPU
# --------------------------------------------------------------
# Note : sur ostree (bazzite/fedora-ostree), mitigations=off est déjà géré dans
# setup_zswap_ostree() pour éviter la duplication. Cette section ne s'applique
# qu'aux distros non-ostree (arch, fedora, debian).
if [[ "${DISABLE_CPU_MITIGATIONS:-0}" == "1" ]]; then
    title "$(t m07_mitig_title)"
    warn "$(t m07_mitig_warn_1)"
    warn "$(t m07_mitig_warn_2)"
    if confirm "$(t m07_mitig_confirm_q)"; then
        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            case "$DISTRO" in
                bazzite-ostree|fedora-ostree)
                    log "[DRY-RUN] $(t m07_mitig_ostree_done)"
                    ;;
                arch|fedora|debian)
                    log "[DRY-RUN] $(t m07_mitig_grub_1)"
                    log "[DRY-RUN] $(t m07_mitig_grub_2_dry)"
                    ;;
            esac
            flag_reboot_needed
            log "[DRY-RUN] $(t m07_mitig_done)"
        else
            case "$DISTRO" in
                bazzite-ostree|fedora-ostree)
                    log "$(t m07_mitig_ostree_done)"
                    ;;
                arch|fedora|debian)
                    warn "$(t m07_mitig_grub_1)"
                    warn "$(t m07_mitig_grub_2)"
                    ;;
            esac
            log "$(t m07_mitig_done)"
        fi
    fi
else
    log "$(t m07_mitig_skipped)"
fi

if [[ "${INSTALL_MANGOHUD:-1}" == "1" ]]; then
    install_mangohud
fi

maybe_prompt_reboot
log "$(t m07_done)"
