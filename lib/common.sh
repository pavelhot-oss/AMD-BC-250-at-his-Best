#!/usr/bin/env bash
# lib/common.sh — fonctions partagées par tous les modules de bc250-beast
# Source ce fichier, ne pas l'exécuter directement.

set -uo pipefail

# ------------------------------------------------------------------
# Couleurs / logging
# ------------------------------------------------------------------
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[0;36m'
C_BOLD='\033[1m'
C_NC='\033[0m'

BC250_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="${BC250_ROOT}/logs/install.log"
mkdir -p "${BC250_ROOT}/logs"

_ts() { date '+%Y-%m-%d %H:%M:%S'; }

log()   { printf "${C_GREEN}[+]${C_NC} %s\n" "$*"; echo "[$(_ts)] [+] $*" >> "$LOG_FILE"; }
warn()  { printf "${C_YELLOW}[!]${C_NC} %s\n" "$*"; echo "[$(_ts)] [!] $*" >> "$LOG_FILE"; }
err()   { printf "${C_RED}[E]${C_NC} %s\n" "$*" >&2; echo "[$(_ts)] [E] $*" >> "$LOG_FILE"; }
die()   { err "$@"; exit 1; }
title() { printf "\n${C_BOLD}${C_CYAN}== %s ==${C_NC}\n" "$*"; }

confirm() {
    # confirm "question" -> return 0 si oui
    local prompt="${1:-Continuer ?}"
    if [[ "${BC250_YES:-0}" == "1" ]]; then
        return 0
    fi
    read -rp "$(printf "${C_YELLOW}%s [y/N]: ${C_NC}" "$prompt")" ans
    [[ "$ans" =~ ^[Yy]$ ]]
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        die "Ce module doit être lancé en root (sudo)."
    fi
}

# ------------------------------------------------------------------
# Détection matérielle : le BC-250 s'identifie par son PCI ID 1002:13FE
# ------------------------------------------------------------------
is_bc250() {
    lspci -n 2>/dev/null | grep -qi '1002:13fe'
}

require_bc250() {
    if [[ "${BC250_FORCE:-0}" == "1" ]]; then
        warn "Détection matérielle ignorée (--force)."
        return 0
    fi
    if ! is_bc250; then
        die "Aucun AMD BC-250 détecté (PCI 1002:13fe absent). Utilisez --force pour ignorer ce garde-fou."
    fi
    log "AMD BC-250 détecté (PCI 1002:13fe)."
}

# ------------------------------------------------------------------
# Détection de distribution / gestionnaire de paquets
# ------------------------------------------------------------------
# Renvoie l'une de : bazzite-ostree | fedora-ostree | fedora | arch | debian | steamos | unknown
detect_distro() {
    if command -v rpm-ostree &>/dev/null; then
        if grep -qi bazzite /etc/os-release 2>/dev/null; then
            echo "bazzite-ostree"
        else
            echo "fedora-ostree"
        fi
    elif grep -qi steamos /etc/os-release 2>/dev/null; then
        echo "steamos"
    elif command -v pacman &>/dev/null; then
        echo "arch"
    elif command -v dnf &>/dev/null; then
        echo "fedora"
    elif command -v apt-get &>/dev/null; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Installe un ou plusieurs paquets quel que soit le gestionnaire détecté.
# Sur les systèmes rpm-ostree (Bazzite/immutable), un reboot est requis après.
pkg_install() {
    local distro; distro="$(detect_distro)"
    case "$distro" in
        bazzite-ostree|fedora-ostree)
            rpm-ostree install --idempotent --apply-live "$@" || {
                warn "install --apply-live a échoué, tentative d'install classique (reboot requis ensuite)"
                rpm-ostree install --idempotent "$@"
                REBOOT_NEEDED=1
            }
            ;;
        fedora)      dnf install -y "$@" ;;
        arch)        pacman -S --needed --noconfirm "$@" ;;
        debian)      apt-get update -qq && apt-get install -y "$@" ;;
        steamos)     die "SteamOS immutable non géré — Bazzite est la distro recommandée par le guide." ;;
        *)           die "Distribution non reconnue, installez manuellement : $*" ;;
    esac
}

REBOOT_NEEDED=0
flag_reboot_needed() { REBOOT_NEEDED=1; }

maybe_prompt_reboot() {
    if [[ "$REBOOT_NEEDED" == "1" ]]; then
        warn "Un redémarrage est nécessaire pour appliquer les changements ci-dessus."
        if confirm "Redémarrer maintenant ?"; then
            systemctl reboot
        else
            warn "N'oubliez pas de redémarrer avant de continuer avec les modules suivants."
        fi
    fi
}

# ------------------------------------------------------------------
# Config utilisateur
# ------------------------------------------------------------------
CONFIG_FILE="${BC250_ROOT}/config/bc250-beast.conf"
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        if [[ -f "${CONFIG_FILE}.example" ]]; then
            cp "${CONFIG_FILE}.example" "$CONFIG_FILE"
            warn "Aucune config trouvée, copie de l'exemple vers $CONFIG_FILE (à ajuster à votre carte)."
        else
            die "Fichier de config introuvable : $CONFIG_FILE"
        fi
    fi
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
}

banner() {
cat <<'EOF'
  ____   ____ ____  _____ ___    ____  _____    _    ____ _____
 | __ ) / ___|___ \| ____/ _ \  | __ )| ____|  / \  / ___|_   _|
 |  _ \| |     __) |  _|| | | | |  _ \|  _|   / _ \ \___ \ | |
 | |_) | |___ / __/| |__| |_| | | |_) | |___ / ___ \ ___) || |
 |____/ \____|_____|_____\___/  |____/|_____/_/   \_\____/ |_|

        AMD BC-250 -> Steam Machine plein potentiel
EOF
}
