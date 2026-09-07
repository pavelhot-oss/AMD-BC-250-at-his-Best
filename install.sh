#!/usr/bin/env bash
# install.sh — Point d'entrée unique de bc250-beast.
#
# Transforme un AMD BC-250 en "bête de course" en orchestrant, dans l'ordre
# recommandé par la communauté (synthèse Old Lamer, docs/guide_old_lamer.md),
# les outils vendorisés (bc250-core-unlock, bc250-cu-live-manager,
# bc250-40cu-unlock, bc250_smu_oc, BIOS UEFI Forbidden-Darkness) et quelques
# réglages système (zswap, mitigations, MangoHud).
#
# Usage : voir --help (texte dans locale/<lang>.sh, clé inst_usage).
#   sudo ./install.sh                 # menu interactif
#   sudo ./install.sh --all           # exécute tous les modules dans l'ordre
#   sudo ./install.sh --module 05     # exécute uniquement le module 05
#   sudo ./install.sh --status        # diagnostic rapide de l'état actuel
#   sudo ./install.sh --lang en|fr    # langue de l'interface (aussi BC250_LANG
#                                      # ou UI_LANG dans la config)
#   sudo ./install.sh --all --yes     # non-interactif
#   sudo ./install.sh --force ...     # ignore la détection PCI du BC-250
set -uo pipefail

export BC250_ROOT
BC250_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${BC250_ROOT}/lib/common.sh"

# Identifiants des modules (ordre = ordre recommandé). Les descriptions
# affichées viennent du catalogue : clé mod_<NN>_desc.
MODULES=(
    "00-preflight"
    "01-cooling-power"
    "02-bios-uefi"
    "03-cpu-core-unlock"
    "04-gpu-cu-unlock"
    "05-cpu-overclock"
    "06-gpu-governor"
    "07-system-tuning"
    "08-extras"
    "09-validation"
)

module_desc() { t "mod_${1%%-*}_desc"; }

usage() {
    t inst_usage
}

run_module() {
    local id="$1"
    local script="${BC250_ROOT}/modules/${id}/run.sh"
    if [[ ! -f "$script" ]]; then
        die "$(t inst_module_not_found "$id")"
    fi
    bash "$script"
    local rc=$?
    if [[ $rc -ne 0 ]]; then
        die "$(t inst_module_failed "$id" "$rc" "$id")"
    fi
}

show_status() {
    banner
    title "$(t inst_status_title)"
    if is_bc250; then
        log "$(t inst_status_bc250_yes)"
    else
        warn "$(t inst_status_bc250_no)"
    fi
    log "$(t inst_status_distro "$(detect_distro)")"
    echo
    t inst_status_threads "$(nproc)"
    grep -q 'mitigations=off' /proc/cmdline 2>/dev/null && t inst_status_mitig_off || t inst_status_mitig_on
    [[ -f /sys/module/zswap/parameters/enabled ]] && t inst_status_zswap "$(cat /sys/module/zswap/parameters/enabled)"
    swapon --show 2>/dev/null | grep -q . && t inst_status_swap_yes || t inst_status_swap_no
    systemctl is-enabled bc250-core-unlock.service &>/dev/null && t inst_status_unlock_svc
    systemctl is-enabled bc250-smu-oc &>/dev/null && t inst_status_oc_svc
    command -v umr &>/dev/null && t inst_status_umr_yes || t inst_status_umr_no
    echo
    t inst_status_gpu_hint
    echo "    sudo ${BC250_ROOT}/vendor/bc250-cu-live-manager/bc250-cu-live-manager.sh status"
}

# Sous-menu de langue : bascule immédiate + proposition d'enregistrement
# dans la config (UI_LANG) pour les prochains lancements.
choose_language_menu() {
    if i18n_prompt_language; then
        if confirm "$(t i18n_save_q "$CONFIG_FILE")"; then
            if i18n_save_to_config "$I18N_LANG"; then
                log "$(t i18n_saved "$I18N_LANG")"
            else
                warn "$(t i18n_save_failed "$CONFIG_FILE")"
            fi
        fi
    else
        warn "$(t inst_invalid_choice)"
    fi
}

interactive_menu() {
    while true; do
        clear
        banner
        echo
        t inst_menu_config "$CONFIG_FILE"
        t inst_menu_lang "$(i18n_lang_name "$I18N_LANG") (${I18N_LANG})"
        echo
        local i=0
        for id in "${MODULES[@]}"; do
            i=$((i+1))
            printf "  %2d) [%s] %s\n" "$i" "$id" "$(module_desc "$id")"
        done
        echo
        echo "   $(t inst_menu_all)"
        echo "   $(t inst_menu_status)"
        echo "   $(t inst_menu_edit)"
        echo "   $(t inst_menu_lang_opt)"
        echo "   $(t inst_menu_quit)"
        echo
        read -rp "$(t inst_prompt_choice)" choice
        case "$choice" in
            q) exit 0 ;;
            s) show_status; read -rp "$(t inst_press_enter)" _ ;;
            e) "${EDITOR:-nano}" "$CONFIG_FILE" ;;
            l) choose_language_menu; sleep 1 ;;
            a)
                for id in "${MODULES[@]}"; do
                    run_module "$id"
                done
                read -rp "$(t inst_done_press_enter)" _
                ;;
            ''|*[!0-9]*)
                warn "$(t inst_invalid_choice)" ; sleep 1 ;;
            *)
                if (( choice >= 1 && choice <= ${#MODULES[@]} )); then
                    run_module "${MODULES[$((choice-1))]}"
                    read -rp "$(t inst_done_press_enter)" _
                else
                    warn "$(t inst_invalid_choice)" ; sleep 1
                fi
                ;;
        esac
    done
}

# ------------------------------------------------------------------
# Parsing des arguments
# ------------------------------------------------------------------
MODE="menu"
TARGET_MODULE=""
# Respecte une variable d'env déjà positionnée (ex: BC250_YES=1 en CI),
# tout en gardant --yes/--force comme méthode normale d'activation.
export BC250_YES="${BC250_YES:-0}"
export BC250_FORCE="${BC250_FORCE:-0}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)        MODE="all" ;;
        --module)     MODE="one"; TARGET_MODULE="${2:-}"; shift ;;
        --status)     MODE="status" ;;
        --yes)        BC250_YES=1 ;;
        --force)      BC250_FORCE=1 ;;
        --lang)
            [[ -n "${2:-}" ]] || die "$(t inst_lang_needs_arg "$(i18n_supported)")"
            i18n_set "$2" || die "$(t i18n_invalid "$2" "$(i18n_supported)")"
            shift ;;
        --lang=*)
            i18n_set "${1#--lang=}" || die "$(t i18n_invalid "${1#--lang=}" "$(i18n_supported)")" ;;
        -h|--help)    usage; exit 0 ;;
        *)            die "$(t inst_unknown_arg "$1")" ;;
    esac
    shift
done

# ------------------------------------------------------------------
# Langue : premier lancement interactif sans choix explicite -> on
# demande avant de créer la config (l'exemple copié suit la langue).
# Ensuite UI_LANG dans la config prend le relais, sauf si --lang /
# BC250_LANG ont été donnés.
# ------------------------------------------------------------------
FIRST_RUN_LANG_CHOSEN=0
if [[ "$MODE" == "menu" && ! -f "$CONFIG_FILE" && "$I18N_EXPLICIT" == "0" && -t 0 ]]; then
    banner
    if i18n_prompt_language; then
        FIRST_RUN_LANG_CHOSEN=1
    fi
fi

load_config

if [[ "$FIRST_RUN_LANG_CHOSEN" == "1" ]]; then
    i18n_save_to_config "$I18N_LANG" && log "$(t i18n_saved "$I18N_LANG")"
elif [[ "$I18N_EXPLICIT" == "0" && -n "${UI_LANG:-}" ]]; then
    i18n_load "$UI_LANG" || warn "$(t i18n_invalid "$UI_LANG" "$(i18n_supported)")"
fi
# Les modules tournent en sous-processus : la langue leur est transmise
# par BC250_LANG (exporté par i18n_load).
export BC250_LANG

case "$MODE" in
    status) show_status ;;
    all)
        banner
        for id in "${MODULES[@]}"; do
            run_module "$id"
        done
        # Demander validation finale (sauf si --yes)
        if [[ "${BC250_YES:-0}" != "1" ]]; then
            echo
            if confirm "$(t inst_final_validation_q)"; then
                run_module "09-validation"
            fi
        else
            log "$(t inst_yes_mode_validation)"
            run_module "09-validation"
        fi
        ;;
    one)
        [[ -n "$TARGET_MODULE" ]] || die "$(t inst_module_needs_id)"
        # Autorise un numéro seul (ex: --module 05)
        if [[ "$TARGET_MODULE" =~ ^[0-9]+$ ]]; then
            match=$(printf '%s\n' "${MODULES[@]}" | grep -E "^0*${TARGET_MODULE}-" || true)
            [[ -n "$match" ]] || die "$(t inst_no_module_number "$TARGET_MODULE")"
            TARGET_MODULE="$match"
        fi
        run_module "$TARGET_MODULE"
        ;;
    menu) interactive_menu ;;
esac
