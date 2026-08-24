#!/usr/bin/env bash
# Module 08 — Extras optionnels (non essentiels, purement informatif +
# quelques installeurs légers à la demande). Sous-menu interactif.
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "08 - Extras optionnels"

# ------------------------------------------------------------------
# Affichage d'intro (conservé de l'original)
# ------------------------------------------------------------------
cat <<'EOF'
Cette section regroupe des extras optionnels évoqués dans les vidéos
d'Old Lamer, non essentiels au fonctionnement de base :

  1) Boîtiers 3D imprimés recommandés
       - NextGen3D (boutique)  : https://nexgen3d.bigcartel.com/
       - NextGen3D (modèles)   : https://www.printables.com/@NexGen3D
       - Steam Machine Pro watercooling 240mm :
           https://www.printables.com/model/1614131-nexgen3d-diy-steam-machine-pro-liquid-cooled-bc-25
       - Alternative ventirad CPU :
           https://www.printables.com/model/1574416-amd-bc-250-with-cpu-cooler

  2) NullVRS (Vulkan layer, utile pour certains titres type Doom: The
     Dark Ages sur GPU cutdown) : https://github.com/bangstk/Vulkan_NullVRS

  3) DLSS Enabler / Lossless Scaling via Decky Loader (Frame Generation)
       - Nécessite Decky Loader installé sur Bazzite/SteamOS-like au
         préalable (non inclus ici, voir le Decky Loader officiel).

  4) Écran USB 3.5" IPS de monitoring (Turing Smart Screen) :
       https://github.com/mathoudebine/turing-smart-screen-python

  5) Communautés :
       Discord : https://discord.com/invite/8eZfFWhczz
       Telegram (UA/RU) : https://t.me/BC250public
EOF

echo

# ------------------------------------------------------------------
# Fonctions d'action pour chaque option du sous-menu
# ------------------------------------------------------------------
install_nullvrs() {
    local layer_dir user_home target_user
    target_user="${SUDO_USER:-$USER}"
    user_home="$(getent passwd "$target_user" | cut -d: -f6)"
    if [[ -z "$user_home" ]]; then
        die "Impossible de déterminer le home de l'utilisateur (${target_user})."
    fi
    layer_dir="${user_home}/.local/share/vulkan/implicit_layer.d"

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] mkdir -p $layer_dir"
        log "[DRY-RUN] Télécharger https://github.com/bangstk/Vulkan_NullVRS/releases/download/1.0.0/NullVRS_Linux_x86_64.tar.gz"
        log "[DRY-RUN] Extraire dans /tmp/nullvrs et copier *.json + *.so vers $layer_dir"
        log "[DRY-RUN] chown -R ${target_user}:${target_user} ${user_home}/.local/share/vulkan"
        return 0
    fi

    require_root
    mkdir -p "$layer_dir"
    cd /tmp
    rm -rf /tmp/nullvrs NullVRS_Linux_x86_64.tar.gz
    log "Téléchargement de NullVRS 1.0.0..."
    curl -L -o NullVRS_Linux_x86_64.tar.gz \
        https://github.com/bangstk/Vulkan_NullVRS/releases/download/1.0.0/NullVRS_Linux_x86_64.tar.gz
    mkdir -p /tmp/nullvrs
    tar -xzf NullVRS_Linux_x86_64.tar.gz -C /tmp/nullvrs
    find /tmp/nullvrs -name "*.json" -exec cp -v {} "${layer_dir}/" \;
    find /tmp/nullvrs -name "*.so"   -exec cp -v {} "${layer_dir}/" \;
    chown -R "${target_user}:${target_user}" "${user_home}/.local/share/vulkan"
    log "NullVRS installé dans ${layer_dir} (appartenant à ${target_user}) :"
    ls -lh "${layer_dir}"/*NullVRS* 2>/dev/null || warn "Fichiers non trouvés, vérifiez l'archive téléchargée."
}

prepare_turing_screen() {
    local vendor_dir="${BC250_ROOT}/vendor/turing-smart-screen-python"
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] git clone https://github.com/mathoudebine/turing-smart-screen-python.git $vendor_dir"
        return 0
    fi

    if [[ -d "$vendor_dir" ]]; then
        log "Dépôt déjà présent dans $vendor_dir, mise à jour..."
        git -C "$vendor_dir" pull || warn "Échec du pull."
    else
        log "Clonage de turing-smart-screen-python..."
        git clone https://github.com/mathoudebine/turing-smart-screen-python.git "$vendor_dir"
    fi

    echo
    printf "${C_GREEN}✓ Cloné dans : ${C_CYAN}%s${C_NC}\n" "$vendor_dir"
    echo
    echo "Prochaines étapes (à faire manuellement selon votre distribution) :"
    echo "  1) cd $vendor_dir"
    echo "  2) Créer un environnement virtuel Python : python3 -m venv venv && source venv/bin/activate"
    echo "  3) pip install -r requirements.txt"
    echo "  4) Configurer l'écran (voir README du dépôt : config.yaml, rotation, port USB)"
    echo "  5) Tester : python main.py"
    echo "  6) Pour le service systemd : copier turing-screen.service vers /etc/systemd/system/ et adapter les chemins"
    echo
    log "Consultez le README du dépôt pour la configuration complète."
}

show_community_links() {
    echo
    title "Liens communauté BC-250"
    printf "  ${C_CYAN}Discord${C_NC}      : ${C_GREEN}https://discord.com/invite/8eZfFWhczz${C_NC}\n"
    printf "  ${C_CYAN}Telegram (UA/RU)${C_NC} : ${C_GREEN}https://t.me/BC250public${C_NC}\n"
    printf "  ${C_CYAN}Boutique NextGen3D${C_NC} : ${C_GREEN}https://nexgen3d.bigcartel.com/${C_NC}\n"
    printf "  ${C_CYAN}Modèles Printables${C_NC} : ${C_GREEN}https://www.printables.com/@NexGen3D${C_NC}\n"
    printf "  ${C_CYAN}Steam Machine Pro (240mm)${C_NC} : ${C_GREEN}https://www.printables.com/model/1614131${C_NC}\n"
    printf "  ${C_CYAN}Alternative ventirad CPU${C_NC} : ${C_GREEN}https://www.printables.com/model/1574416${C_NC}\n"
    echo
}

# ------------------------------------------------------------------
# Boucle du sous-menu interactif
# ------------------------------------------------------------------
while true; do
    echo
    title "Sous-menu Extras"
    echo "  1) Installer Vulkan NullVRS (v1.0.0)"
    echo "  2) Préparer Turing Smart Screen 3.5\" (clone + instructions)"
    echo "  3) Afficher les liens communauté (formatés)"
    echo "  q) Retour / Quitter"
    echo
    read -rp "$(printf "${C_YELLOW}Choix [1-3/q] : ${C_NC}")" choice

    case "$choice" in
        1) install_nullvrs ;;
        2) prepare_turing_screen ;;
        3) show_community_links ;;
        q|Q) break ;;
        *) warn "Choix invalide." ;;
    esac
done

log "Module 08 terminé."