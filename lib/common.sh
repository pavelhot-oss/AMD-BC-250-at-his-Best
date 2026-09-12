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

# ------------------------------------------------------------------
# Config utilisateur (chemin défini ici, chargé par load_config plus bas,
# et utilisé par i18n pour persister le choix de langue)
# ------------------------------------------------------------------
CONFIG_FILE="${BC250_ROOT}/config/bc250-beast.conf"

# ------------------------------------------------------------------
# i18n : tous les messages passent par t <clé> (voir lib/i18n.sh et
# locale/*.sh). Chargé ici, après les fonctions de log qu'il utilise.
# ------------------------------------------------------------------
# shellcheck disable=SC1091
source "${BC250_ROOT}/lib/i18n.sh"
i18n_init

confirm() {
    # confirm "question" -> return 0 si oui
    local prompt="${1:-$(t common_confirm_default)}"
    if [[ "${BC250_YES:-0}" == "1" ]]; then
        return 0
    fi
    local yes_re; yes_re="$(t common_yes_regex)"
    read -rp "$(printf "${C_YELLOW}%s %s: ${C_NC}" "$prompt" "$(t common_yn)")" ans
    [[ "$ans" =~ $yes_re ]]
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        die "$(t common_need_root)"
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
        warn "$(t common_hw_check_skipped)"
        return 0
    fi
    if ! is_bc250; then
        die "$(t common_no_bc250)"
    fi
    log "$(t common_bc250_found)"
}

# ------------------------------------------------------------------
# Détection du chemin pp_dpm_sclk du GPU AMD. L'index DRM (card0, card1, …)
# varie selon la présence d'autres cartes (IGP, …) : on parcourt tous les
# /sys/class/drm/card*/ et on renvoie la première entrée lisible. Retourne
# vide (rc=1) si aucun chemin n'est trouvé.
# ------------------------------------------------------------------
find_drm_sclk() {
    local card p
    for card in /sys/class/drm/card*/; do
        p="${card}device/pp_dpm_sclk"
        if [[ -r "$p" ]]; then
            printf '%s' "$p"
            return 0
        fi
    done
    return 1
}

# ------------------------------------------------------------------
# Chemin du fichier mem_info_vram_total (octets) du GPU AMD, auto-détecté
# comme find_drm_sclk (ne pas hardcoder card0/card1). Vide (rc=1) si absent.
# ------------------------------------------------------------------
find_drm_vram_total() {
    local card f
    for card in /sys/class/drm/card*/; do
        f="${card}device/mem_info_vram_total"
        if [[ -r "$f" ]]; then
            printf '%s' "$f"
            return 0
        fi
    done
    return 1
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
                warn "$(t common_apply_live_failed)"
                rpm-ostree install --idempotent "$@"
                REBOOT_NEEDED=1
            }
            ;;
        fedora)      dnf install -y "$@" ;;
        arch)        pacman -S --needed --noconfirm "$@" ;;
        debian)      apt-get update -qq && apt-get install -y "$@" ;;
        steamos)     die "$(t common_steamos_unsupported)" ;;
        *)           die "$(t common_unknown_distro_pkg "$*")" ;;
    esac
}

REBOOT_NEEDED=0
flag_reboot_needed() { REBOOT_NEEDED=1; }

maybe_prompt_reboot() {
    if [[ "$REBOOT_NEEDED" == "1" ]]; then
        warn "$(t common_reboot_needed)"
        if confirm "$(t common_reboot_now_q)"; then
            systemctl reboot
        else
            warn "$(t common_reboot_reminder)"
        fi
    fi
}

# ------------------------------------------------------------------
# Session graphique réelle (helper pour les stress GUI)
# ------------------------------------------------------------------
# Quand les modules tournent sous sudo/root (ex. `sudo ./install.sh --module
# 09`), FurMark + MangoHud héritent d'un environnement SANS display :
# root n'a ni DISPLAY ni XAUTHORITY ni accès au socket Wayland de l'utilisateur
# graphique — c'est la cause du `cannot open default display!` immédiat =
# stress GPU "terminé en 0,5 s" => faussement marqué instable.
#
# graphical_session_env : détecte le vrai utilisateur graphique (celui qui a
# langé la session X/Wayland) et reconstruit son environnement d'affichage.
# Best-effort : si aucune session graphique n'est trouvée (SSH/headless), la
# fonction retourne 1 et le module concerné le signale en "warn", il ne
# fabrique pas un grand FAIL.
#
# Usage dans un module :
#   if graphical_session_env; then
#       log "stress GPU dans la session de ${GX_USER} ($DISPLAY)"
#       runuser -u "$GX_USER" -- env "${GX_ENV[@]}" mangohud "$bin" ... 
#   else
#       report_result "..." "warn" "pas de session graphique (headless/SSH)"
#   fi
# Variables de sortie : GX_USER, GX_ENV (tableau KEY=VALUE à injecter),
# GX_DISPLAY_FOUND (0/1).
# ------------------------------------------------------------------
GX_USER=""
GX_DISPLAY_FOUND=0

graphical_session_env() {
    GX_USER=""
    GX_ENV=()
    GX_DISPLAY_FOUND=0

    # L'utilisateur graphique = celui qui a lancé sudo (jamais root).
    local _gx_real_user="${SUDO_USER:-${USER:-}}"
    if [[ -z "$_gx_real_user" || "$_gx_real_user" == "root" ]]; then
        # Dernier recours : le plus récent propriétaire d'un /run/user/<uid>
        # (artefact de session graphique obligatoire sous Wayland/X).
        local _uid _pe
        for _uid in $(find /run/user -maxdepth 1 -mindepth 1 -type d -printf '%f ' 2>/dev/null); do
            _pe=$(getent passwd "$_uid" 2>/dev/null | cut -d: -f1)
            [[ -z "$_pe" || "$_pe" == "root" ]] && continue
            _gx_real_user="$_pe"
            break
        done
    fi
    [[ -z "$_gx_real_user" || "$_gx_real_user" == "root" ]] && return 1

    local _gx_uid _runtime _sock _pid _display _wayland _xauth
    _gx_uid="$(id -u "$_gx_real_user" 2>/dev/null)" || return 1
    _runtime="/run/user/${_gx_uid}"

    # Preuve qu'il existe une vraie session graphique : un processus de
    # l'utilisateur avec DISPLAY/WAYLAND_DISPLAY dans /proc/[...]/environ
    # (plutôt que de deviner :0).
    local _cand
    for _pid in $(pgrep -u "$_gx_uid" 2>/dev/null); do
        _display="$(tr '\0' '\n' < "/proc/${_pid}/environ" 2>/dev/null | sed -n 's/^DISPLAY=//p' | head -1)"
        _wayland="$(tr '\0' '\n' < "/proc/${_pid}/environ" 2>/dev/null | sed -n 's/^WAYLAND_DISPLAY=//p' | head -1)"
        if [[ -n "$_display" || -n "$_wayland" ]]; then
            GX_USER="$_gx_real_user"
            GX_DISPLAY_FOUND=1
            break
        fi
    done

    # Même sans process visible (session vide), on s'appuie sur les sockets :
    # le display peut encore être mappé via le socket Wayland du XDG_RUNTIME.
    local _wsock
    if (( GX_DISPLAY_FOUND == 0 )); then
        _wsock=$(find "$_runtime" -maxdepth 1 -name 'wayland-*' -printf '%f\n' 2>/dev/null | head -1)
        if [[ -n "$_wsock" && -S "$_runtime/$_wsock" ]]; then
            GX_USER="$_gx_real_user"
            GX_DISPLAY_FOUND=1
        fi
    fi

    (( GX_DISPLAY_FOUND == 0 )) && return 1

    # Reconstruit l'environnement d'affichage à injecter dans le stress.
    GX_ENV=()
    if [[ -n "$_display" ]]; then
        GX_ENV+=(DISPLAY="$_display")
    else
        GX_ENV+=(DISPLAY=":0")
    fi
    if [[ -n "$_wayland" ]]; then
        GX_ENV+=(WAYLAND_DISPLAY="$_wayland")
    fi
    GX_ENV+=(XDG_RUNTIME_DIR="$_runtime")
    local _gx_sess _gx_stype
    _gx_sess="$(loginctl | awk -v u="$_gx_real_user" '$1 ~ /^[0-9]+/ && $3==u {print $1; exit}' 2>/dev/null)"
    _gx_stype="$(loginctl show-session "$_gx_sess" 2>/dev/null | sed -n 's/^Type=//p')"
    if [[ -n "$_gx_stype" ]]; then
        GX_ENV+=(XDG_SESSION_TYPE="$_gx_stype")
    fi

    # XAUTHORITY : on ne peut pas deviner le fichier ; on refile celui du
    # processus candidat s'il en avait un, sinon le ~/.Xauthority de
    # l'utilisateur (best-effort).
    for _pid in $(pgrep -u "$_gx_uid" 2>/dev/null); do
        _xauth="$(tr '\0' '\n' < "/proc/${_pid}/environ" 2>/dev/null | sed -n 's/^XAUTHORITY=//p' | head -1)"
        if [[ -n "$_xauth" ]]; then
            GX_ENV+=(XAUTHORITY="$_xauth")
            break
        fi
    done
    if [[ -z "$(printf '%s\n' "${GX_ENV[@]}" | grep -q '^XAUTHORITY=' && echo found)" ]] && \
       [[ -f "/home/$_gx_real_user/.Xauthority" ]]; then
        GX_ENV+=(XAUTHORITY="/home/$_gx_real_user/.Xauthority")
    fi
    return 0
}

# ------------------------------------------------------------------
# Chargement de la config
# ------------------------------------------------------------------
# Au premier lancement, copie l'exemple dans la langue active s'il existe
# (bc250-beast.conf.example.fr), sinon l'exemple anglais par défaut.
# Les variables sont exportées (set -a) : les modules tournent dans un
# sous-shell (bash modules/XX/run.sh) et ne verraient rien sinon.
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        local example="${CONFIG_FILE}.example"
        [[ -f "${example}.${I18N_LANG}" ]] && example="${example}.${I18N_LANG}"
        if [[ -f "$example" ]]; then
            cp "$example" "$CONFIG_FILE"
            warn "$(t common_config_created "$CONFIG_FILE")"
        else
            die "$(t common_config_missing "$CONFIG_FILE")"
        fi
    fi
    set -a
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
    set +a
}

banner() {
cat <<'EOF'
  ____   ____ ____  _____ ___    ____  _____    _    ____ _____
 | __ ) / ___|___ \| ____/ _ \  | __ )| ____|  / \  / ___|_   _|
 |  _ \| |     __) |  _|| | | | |  _ \|  _|   / _ \ \___ \ | |
 | |_) | |___ / __/| |__| |_| | | |_) | |___ / ___ \ ___) || |
 |____/ \____|_____|_____\___/  |____/|_____/_/   \_\____/ |_|

EOF
printf '        %s\n' "$(t common_banner_tagline)"
}
