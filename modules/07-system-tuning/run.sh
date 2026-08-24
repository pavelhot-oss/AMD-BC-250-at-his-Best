#!/usr/bin/env bash
# Module 07 — Réglages système : zswap (anti-crash RAM/VRAM), mitigations
# CPU désactivées, MangoHud pour le monitoring en jeu.
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "07 - Réglages système (zswap / mitigations / MangoHud)"
require_root

DISTRO="$(detect_distro)"

# --------------------------------------------------------------
# zswap + swapfile Btrfs 32Go (procédure Bazzite/rpm-ostree exacte,
# issue de la description officielle de la vidéo Part XIV)
# --------------------------------------------------------------
setup_zswap_ostree() {
    log "Activation de zswap + mitigations=off via kernel args (rpm-ostree)..."
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
        warn "[DRY-RUN] Un reboot serait nécessaire (système immutable rpm-ostree)."
        return 0
    fi

    rpm-ostree kargs --append-if-missing "${zswap_args[@]}"
    rpm-ostree kargs --append-if-missing "${mitigation_args[@]}"
    rpm-ostree initramfs --enable --arg=--add-drivers --arg="${ZSWAP_COMPRESSOR:-lz4}"
    flag_reboot_needed
    warn "Un reboot est nécessaire (système immutable rpm-ostree)."
    warn "Relancez ce module après le reboot : il détectera que les kernel args sont déjà actifs."
}

setup_swapfile_btrfs() {
    local size="${SWAPFILE_SIZE_GB:-32}"
    if ! findmnt -no FSTYPE /var &>/dev/null || [[ "$(findmnt -no FSTYPE /var)" != "btrfs" ]]; then
        warn "/var n'est pas sur Btrfs sur ce système — la procédure officielle (swapfile Btrfs"
        warn "dédié) ne s'applique pas telle quelle. Créez un swapfile classique manuellement,"
        warn "ou passez ce sous-module si vous n'êtes pas sur Bazzite/Btrfs."
        return 0
    fi

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] swapoff -a"
        log "[DRY-RUN] rm -rf /var/swap (si existant)"
        log "[DRY-RUN] btrfs subvolume create /var/swap"
        if command -v semanage &>/dev/null; then
            log "[DRY-RUN] semanage fcontext -a -t var_t '/var/swap(/.*)?'"
            log "[DRY-RUN] restorecon -Rv /var/swap"
        else
            log "[DRY-RUN] rpm-ostree install --idempotent policycoreutils-python-utils (reboot requis)"
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
        log "[DRY-RUN] Vérification finale : rpm-ostree kargs, zswap enabled, swappiness, swapon --show"
        return 0
    fi

    log "Désactivation du swap existant..."
    swapoff -a || true

    if [[ -d /var/swap ]]; then
        log "Suppression de l'ancien /var/swap..."
        rm -rf /var/swap
    fi

    log "Création du subvolume Btrfs /var/swap..."
    btrfs subvolume create /var/swap

    if command -v semanage &>/dev/null; then
        log "Correction du contexte SELinux..."
        semanage fcontext -a -t var_t "/var/swap(/.*)?"
        restorecon -Rv /var/swap
    else
        warn "semanage absent, installation de policycoreutils-python-utils requise (rpm-ostree, reboot)."
        rpm-ostree install --idempotent policycoreutils-python-utils
        flag_reboot_needed
        warn "Relancez ce sous-module après reboot pour finir le SELinux + créer le swapfile."
        return 0
    fi

    log "Création du swapfile de ${size}G..."
    btrfs filesystem mkswapfile --size "${size}G" /var/swap/swapfile
    semanage fcontext -a -t swapfile_t "/var/swap/swapfile"
    restorecon -v /var/swap/swapfile

    log "Ajout à /etc/fstab..."
    sed -i '\|/var/swap/swapfile|d' /etc/fstab
    echo "/var/swap/swapfile none swap defaults,nofail 0 0" >> /etc/fstab

    log "Activation immédiate du swap..."
    swapon -a
    swapon --show

    local swappiness="${SWAPPINESS:-120}"
    log "Réglage de vm.swappiness=${swappiness} (optimisé jeu)..."
    echo "vm.swappiness=${swappiness}" > /etc/sysctl.d/99-swappiness.conf
    sysctl -p /etc/sysctl.d/99-swappiness.conf

    log "Vérification finale :"
    rpm-ostree kargs 2>/dev/null | grep -o 'zswap[^ ]*' || true
    cat /sys/module/zswap/parameters/enabled 2>/dev/null || warn "zswap pas encore actif (reboot en attente ?)"
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
    title "Installation de MangoHud (overlay FPS/temp/usage GPU-CPU)"

    # Détection steamos (Steam Deck / SteamOS) — MangoHud préinstallé
    local is_steamos=0
    if grep -qi 'steamos' /etc/os-release 2>/dev/null; then
        is_steamos=1
    fi

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        case "$DISTRO" in
            bazzite-ostree)
                log "[DRY-RUN] MangoHud est généralement préinstallé sur Bazzite. Vérification : command -v mangohud || pkg_install mangohud" ;;
            steamos|fedora-ostree|fedora)
                if [[ $is_steamos -eq 1 ]]; then
                    log "[DRY-RUN] MangoHud préinstallé sur SteamOS — skip installation"
                else
                    log "[DRY-RUN] pkg_install mangohud"
                fi
                ;;
            arch)   log "[DRY-RUN] pkg_install mangohud" ;;
            debian) log "[DRY-RUN] pkg_install mangohud" ;;
        esac
        log "[DRY-RUN] Pour activer dans Steam : ajoutez 'mangohud %command%' aux options de lancement d'un jeu."
    else
        case "$DISTRO" in
            bazzite-ostree)
                log "MangoHud est généralement préinstallé sur Bazzite. Vérification..."
                command -v mangohud &>/dev/null && log "MangoHud déjà présent." || pkg_install mangohud ;;
            steamos|fedora-ostree|fedora)
                if [[ $is_steamos -eq 1 ]]; then
                    log "MangoHud préinstallé sur SteamOS — skip installation"
                else
                    pkg_install mangohud
                fi
                ;;
            arch)   pkg_install mangohud ;;
            debian) pkg_install mangohud ;;
        esac
        log "Pour activer dans Steam : ajoutez 'mangohud %command%' aux options de lancement d'un jeu."
    fi
}

if [[ "${ENABLE_ZSWAP:-1}" == "1" ]]; then
    case "$DISTRO" in
        bazzite-ostree|fedora-ostree)
            if rpm-ostree kargs 2>/dev/null | grep -q 'zswap.enabled=1'; then
                log "zswap déjà activé au niveau kernel, passage direct à la création du swapfile."
                setup_swapfile_btrfs
            else
                setup_zswap_ostree
            fi
            ;;
        arch|fedora|debian)
            warn "Procédure officielle zswap+swapfile documentée pour Bazzite/rpm-ostree+Btrfs uniquement."
            warn "Sur $DISTRO : activez zswap via GRUB_CMDLINE_LINUX (zswap.enabled=1 zswap.max_pool_percent=${ZSWAP_MAX_POOL_PERCENT:-25} zswap.compressor=${ZSWAP_COMPRESSOR:-lz4})"
            warn "puis régénérez votre config bootloader (grub-mkconfig / bootctl / etc. selon votre setup), et créez un swapfile classique."
            ;;
    esac
else
    warn "ENABLE_ZSWAP=0 dans la config, étape ignorée."
fi

# --------------------------------------------------------------
# Mitigations CPU
# --------------------------------------------------------------
# Note : sur ostree (bazzite/fedora-ostree), mitigations=off est déjà géré dans
# setup_zswap_ostree() pour éviter la duplication. Cette section ne s'applique
# qu'aux distros non-ostree (arch, fedora, debian).
if [[ "${DISABLE_CPU_MITIGATIONS:-0}" == "1" ]]; then
    title "Désactivation des mitigations CPU (Spectre/Meltdown)"
    warn "Ceci réduit la protection contre certaines attaques locales (side-channel)."
    warn "Recommandé uniquement sur une machine de jeu dédiée, pas un poste multi-usage sensible."
    if confirm "Confirmer la désactivation des mitigations CPU ?"; then
        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            case "$DISTRO" in
                bazzite-ostree|fedora-ostree)
                    log "[DRY-RUN] mitigations=off déjà appliqué via setup_zswap_ostree (rpm-ostree kargs)"
                    ;;
                arch|fedora|debian)
                    log "[DRY-RUN] Ajoutez 'mitigations=off' à GRUB_CMDLINE_LINUX (ou votre config systemd-boot),"
                    log "[DRY-RUN] puis régénérez la config du bootloader (grub-mkconfig / bootctl / etc.) et redémarrez."
                    ;;
            esac
            flag_reboot_needed
            log "[DRY-RUN] Mitigations désactivées (effectif après reboot)."
        else
            case "$DISTRO" in
                bazzite-ostree|fedora-ostree)
                    log "mitigations=off déjà appliqué via setup_zswap_ostree (rpm-ostree kargs)"
                    ;;
                arch|fedora|debian)
                    warn "Ajoutez 'mitigations=off' à GRUB_CMDLINE_LINUX (ou votre config systemd-boot),"
                    warn "puis régénérez la config du bootloader et redémarrez."
                    ;;
            esac
            log "Mitigations désactivées (effectif après reboot)."
        fi
    fi
else
    log "DISABLE_CPU_MITIGATIONS=0 (ou absent), étape ignorée."
fi

if [[ "${INSTALL_MANGOHUD:-1}" == "1" ]]; then
    install_mangohud
fi

maybe_prompt_reboot
log "Module 07 terminé."
