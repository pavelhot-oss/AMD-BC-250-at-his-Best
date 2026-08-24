#!/usr/bin/env bash
# install.sh — Point d'entrée unique de bc250-beast.
#
# Transforme un AMD BC-250 en "bête de course" en orchestrant, dans l'ordre
# recommandé par la communauté (synthèse Old Lamer, docs/guide_old_lamer.md),
# les outils vendorisés (bc250-core-unlock, bc250-cu-live-manager,
# bc250-40cu-unlock, bc250_smu_oc, BIOS UEFI Forbidden-Darkness) et quelques
# réglages système (zswap, mitigations, MangoHud).
#
# Usage :
#   sudo ./install.sh                 # menu interactif
#   sudo ./install.sh --all           # exécute tous les modules dans l'ordre
#   sudo ./install.sh --module 05     # exécute uniquement le module 05
#   sudo ./install.sh --status        # diagnostic rapide de l'état actuel
#   sudo ./install.sh --all --yes     # non-interactif (utilise les valeurs
#                                      # de config sans confirmation à chaque
#                                      # étape — à réserver à un ré-déploiement
#                                      # d'une config déjà validée manuellement)
#   sudo ./install.sh --force ...     # ignore la détection PCI du BC-250
#                                      # (utile en dev / CI hors matériel réel)
set -uo pipefail

export BC250_ROOT
BC250_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${BC250_ROOT}/lib/common.sh"

MODULES=(
    "00-preflight:Vérifications préalables (matériel, distro, dépendances)"
    "01-cooling-power:Refroidissement & alimentation (checklist physique)"
    "02-bios-uefi:BIOS/UEFI modifié (8 cœurs intégrés + VRAM 512Mo)"
    "03-cpu-core-unlock:Déblocage 8 cœurs CPU (logiciel, avec persistance)"
    "04-gpu-cu-unlock:Déblocage Compute Units GPU (jusqu'à 40 CU)"
    "05-cpu-overclock:Overclock/undervolt CPU (SMU)"
    "06-gpu-governor:Overclock GPU (gouverneur cyan-skillfish)"
    "07-system-tuning:Réglages système (zswap, mitigations, MangoHud)"
    "08-extras:Extras optionnels (boîtiers, NullVRS, liens communauté)"
    "09-validation:Validation & Benchmark"
)

usage() {
    sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

run_module() {
    local id="$1"
    local script="${BC250_ROOT}/modules/${id}/run.sh"
    if [[ ! -f "$script" ]]; then
        die "Module introuvable : $id"
    fi
    bash "$script"
    local rc=$?
    if [[ $rc -ne 0 ]]; then
        die "Le module ${id} a échoué (code ${rc}). Arrêt de la séquence — corrigez le problème puis relancez avec --module ${id}."
    fi
}

show_status() {
    banner
    title "État actuel"
    if is_bc250; then
        log "AMD BC-250 détecté."
    else
        warn "Aucun AMD BC-250 détecté sur ce système."
    fi
    log "Distribution : $(detect_distro)"
    echo
    echo "CPU threads   : $(nproc)"
    grep -q 'mitigations=off' /proc/cmdline 2>/dev/null && echo "Mitigations   : désactivées" || echo "Mitigations   : actives (stock)"
    [[ -f /sys/module/zswap/parameters/enabled ]] && echo "zswap         : $(cat /sys/module/zswap/parameters/enabled)"
    swapon --show 2>/dev/null | grep -q . && echo "Swap actif    : oui" || echo "Swap actif    : non"
    systemctl is-enabled bc250-core-unlock.service &>/dev/null && echo "Unlock 8 cores (service) : activé"
    systemctl is-enabled bc250-smu-oc &>/dev/null && echo "CPU OC (service)          : activé"
    command -v umr &>/dev/null && echo "umr           : installé" || echo "umr           : absent"
    echo
    echo "Pour le détail GPU (table WGP / CU actives) :"
    echo "    sudo ${BC250_ROOT}/vendor/bc250-cu-live-manager/bc250-cu-live-manager.sh status"
}

interactive_menu() {
    while true; do
        clear
        banner
        echo
        echo "Config active : ${CONFIG_FILE}"
        echo
        local i=0
        for m in "${MODULES[@]}"; do
            i=$((i+1))
            local id="${m%%:*}"
            local desc="${m#*:}"
            printf "  %2d) [%s] %s\n" "$i" "$id" "$desc"
        done
        echo
        echo "   a) Tout exécuter dans l'ordre recommandé"
        echo "   s) Statut / diagnostic"
        echo "   e) Éditer la config (\$EDITOR)"
        echo "   q) Quitter"
        echo
        read -rp "Choix : " choice
        case "$choice" in
            q) exit 0 ;;
            s) show_status; read -rp "Entrée pour continuer..." _ ;;
            e) "${EDITOR:-nano}" "$CONFIG_FILE" ;;
            a)
                for m in "${MODULES[@]}"; do
                    run_module "${m%%:*}"
                done
                read -rp "Terminé. Entrée pour continuer..." _
                ;;
            ''|*[!0-9]*)
                warn "Choix invalide." ; sleep 1 ;;
            *)
                if (( choice >= 1 && choice <= ${#MODULES[@]} )); then
                    run_module "${MODULES[$((choice-1))]%%:*}"
                    read -rp "Terminé. Entrée pour continuer..." _
                else
                    warn "Choix invalide." ; sleep 1
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
        --module)     MODE="one"; TARGET_MODULE="$2"; shift ;;
        --status)     MODE="status" ;;
        --yes)        BC250_YES=1 ;;
        --force)      BC250_FORCE=1 ;;
        -h|--help)    usage; exit 0 ;;
        *)            die "Argument inconnu : $1 (voir --help)" ;;
    esac
    shift
done

load_config

case "$MODE" in
    status) show_status ;;
    all)
        banner
        for m in "${MODULES[@]}"; do
            run_module "${m%%:*}"
        done
        # Demander validation finale (sauf si --yes)
        if [[ "${BC250_YES:-0}" != "1" ]]; then
            echo
            if confirm "Voulez-vous lancer la validation finale (module 09) ?"; then
                run_module "09-validation"
            fi
        else
            log "Mode --yes : validation finale automatique."
            run_module "09-validation"
        fi
        ;;
    one)
        [[ -n "$TARGET_MODULE" ]] || die "--module requiert un identifiant (ex: 05-cpu-overclock ou 05)"
        # Autorise un numéro seul (ex: --module 05)
        if [[ "$TARGET_MODULE" =~ ^[0-9]+$ ]]; then
            match=$(printf '%s\n' "${MODULES[@]}" | grep -E "^0*${TARGET_MODULE}-" || true)
            [[ -n "$match" ]] || die "Aucun module ne correspond au numéro $TARGET_MODULE"
            TARGET_MODULE="${match%%:*}"
        fi
        run_module "$TARGET_MODULE"
        ;;
    menu) interactive_menu ;;
esac
