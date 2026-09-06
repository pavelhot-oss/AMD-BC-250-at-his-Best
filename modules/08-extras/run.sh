#!/usr/bin/env bash
# Module 08 — Extras optionnels (non essentiels, purement informatif +
# quelques installeurs légers à la demande). Sous-menu interactif.
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "$(t m08_title)"

# ------------------------------------------------------------------
# Affichage d'intro (conservé de l'original)
# ------------------------------------------------------------------
t m08_intro

echo

# ------------------------------------------------------------------
# Fonctions d'action pour chaque option du sous-menu
# ------------------------------------------------------------------
install_nullvrs() {
    local layer_dir user_home target_user
    target_user="${SUDO_USER:-$USER}"
    user_home="$(getent passwd "$target_user" | cut -d: -f6)"
    if [[ -z "$user_home" ]]; then
        die "$(t m08_no_home "$target_user")"
    fi
    layer_dir="${user_home}/.local/share/vulkan/implicit_layer.d"

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] mkdir -p $layer_dir"
        log "$(t m08_dry_download "https://github.com/bangstk/Vulkan_NullVRS/releases/download/1.0.0/NullVRS_Linux_x86_64.tar.gz")"
        log "$(t m08_dry_extract "$layer_dir")"
        log "[DRY-RUN] chown -R ${target_user}:${target_user} ${user_home}/.local/share/vulkan"
        return 0
    fi

    require_root
    mkdir -p "$layer_dir"
    cd /tmp
    rm -rf /tmp/nullvrs NullVRS_Linux_x86_64.tar.gz
    log "$(t m08_downloading)"
    curl -L -o NullVRS_Linux_x86_64.tar.gz \
        https://github.com/bangstk/Vulkan_NullVRS/releases/download/1.0.0/NullVRS_Linux_x86_64.tar.gz
    mkdir -p /tmp/nullvrs
    tar -xzf NullVRS_Linux_x86_64.tar.gz -C /tmp/nullvrs
    find /tmp/nullvrs -name "*.json" -exec cp -v {} "${layer_dir}/" \;
    find /tmp/nullvrs -name "*.so"   -exec cp -v {} "${layer_dir}/" \;
    chown -R "${target_user}:${target_user}" "${user_home}/.local/share/vulkan"
    log "$(t m08_nullvrs_installed "$layer_dir" "$target_user")"
    ls -lh "${layer_dir}"/*NullVRS* 2>/dev/null || warn "$(t m08_files_not_found)"
}

prepare_turing_screen() {
    local vendor_dir="${BC250_ROOT}/vendor/turing-smart-screen-python"
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] git clone https://github.com/mathoudebine/turing-smart-screen-python.git $vendor_dir"
        return 0
    fi

    if [[ -d "$vendor_dir" ]]; then
        log "$(t m08_repo_update "$vendor_dir")"
        git -C "$vendor_dir" pull || warn "$(t m08_pull_failed)"
    else
        log "$(t m08_cloning_turing)"
        git clone https://github.com/mathoudebine/turing-smart-screen-python.git "$vendor_dir"
    fi

    echo
    printf "${C_GREEN}✓ %s ${C_CYAN}%s${C_NC}\n" "$(t m08_cloned_in)" "$vendor_dir"
    echo
    t m08_turing_steps "$vendor_dir"
    echo
    log "$(t m08_see_readme)"
}

show_community_links() {
    echo
    title "$(t m08_community_title)"
    printf "  ${C_CYAN}%s${C_NC} : ${C_GREEN}https://discord.com/invite/8eZfFWhczz${C_NC}\n" "$(t m08_lbl_discord)"
    printf "  ${C_CYAN}%s${C_NC} : ${C_GREEN}https://t.me/BC250public${C_NC}\n" "$(t m08_lbl_telegram)"
    printf "  ${C_CYAN}%s${C_NC} : ${C_GREEN}https://nexgen3d.bigcartel.com/${C_NC}\n" "$(t m08_lbl_shop)"
    printf "  ${C_CYAN}%s${C_NC} : ${C_GREEN}https://www.printables.com/@NexGen3D${C_NC}\n" "$(t m08_lbl_models)"
    printf "  ${C_CYAN}%s${C_NC} : ${C_GREEN}https://www.printables.com/model/1614131${C_NC}\n" "$(t m08_lbl_smp)"
    printf "  ${C_CYAN}%s${C_NC} : ${C_GREEN}https://www.printables.com/model/1574416${C_NC}\n" "$(t m08_lbl_cooler)"
    echo
}

# ------------------------------------------------------------------
# Boucle du sous-menu interactif
# ------------------------------------------------------------------
while true; do
    echo
    title "$(t m08_submenu_title)"
    echo "  $(t m08_opt_1)"
    echo "  $(t m08_opt_2)"
    echo "  $(t m08_opt_3)"
    echo "  $(t m08_opt_q)"
    echo
    read -rp "$(printf "${C_YELLOW}%s${C_NC}" "$(t m08_prompt)")" choice

    case "$choice" in
        1) install_nullvrs ;;
        2) prepare_turing_screen ;;
        3) show_community_links ;;
        q|Q) break ;;
        *) warn "$(t inst_invalid_choice)" ;;
    esac
done

log "$(t m08_done)"
