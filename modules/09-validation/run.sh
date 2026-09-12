#!/usr/bin/env bash
# Module 09 — Validation & Benchmark
# Lance une batterie de tests automatisés pour valider l'état du système après
# installation complète de bc250-beast.
set -uo pipefail
BC250_ROOT="${BC250_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${BC250_ROOT}/lib/common.sh"

require_bc250

title "$(t m09_title)"

# ------------------------------------------------------------------
# Compteurs de résultats
# ------------------------------------------------------------------
PASS=0
FAIL=0
WARN=0

# ------------------------------------------------------------------
# Gouvernance des cœurs par le BIOS moddé (module 02)
# ------------------------------------------------------------------
# Le BIOS moddé (MeiMeiDXE) peut débloquer/gouverner les cœurs CPU (option
# "Unlock CPU cores"). Dans ce cas le module 03 est sauté et le service
# logiciel bc250-core-unlock n'est NI installé NI requis : certains tests ne
# s'appliquent donc pas. logs/bios_flashed.flag est le même signal que celui
# utilisé par le module 03.
BIOS_GOVERN=0
# Signal n°1 : le flag posé par la confirmation interactive du module 02.
if [[ -f "${BC250_ROOT}/logs/bios_flashed.flag" ]]; then
    BIOS_GOVERN=1
else
    # Signal n°2 (heuristique) : 16 threads présents AU DÉMARRAGE sans service
    # logiciel d'unlock installé. Personne ne peut avoir débloqué les cœurs
    # autrement que par le BIOS (le module 03 saute le binaire quand le flag
    # existe, mais le flag peut manquer si la confirmation interactive du
    # module 02 n'a pas été repassée après un flash "manuel"). Dans ce cas,
    # c'est forcément le BIOS moddé qui gouverne les cœurs.
    if [[ "$(nproc)" -eq 16 ]] && ! systemctl is-enabled --quiet bc250-core-unlock.service 2>/dev/null; then
        BIOS_GOVERN=1
    fi
fi

# ------------------------------------------------------------------
# Fonction de rapport de résultat
# ------------------------------------------------------------------
# Usage: report_result "nom du test" "pass|fail|warn" "message optionnel"
report_result() {
    local test_name="$1"
    local status="$2"
    local message="${3:-}"

    case "$status" in
        pass)
            PASS=$((PASS + 1))
            printf "  ${C_GREEN}✓${C_NC} %-40s %s\n" "$test_name" "${message:-}"
            ;;
        fail)
            FAIL=$((FAIL + 1))
            printf "  ${C_RED}✗${C_NC} %-40s %s\n" "$test_name" "${message:-}"
            ;;
        warn)
            WARN=$((WARN + 1))
            printf "  ${C_YELLOW}⚠${C_NC} %-40s %s\n" "$test_name" "${message:-}"
            ;;
        *)
            die "$(t m09_invalid_status "$status")"
            ;;
    esac
}

# ------------------------------------------------------------------
# Helper DRY_RUN
# ------------------------------------------------------------------
run_cmd() {
    local description="$1"
    shift
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] $description"
        log "$(t m09_dry_cmd "$*")"
        return 0
    fi
    "$@"
}

# ------------------------------------------------------------------
# Fréquence CPU effective (MHz) mesurée SOUS CHARGE
# ------------------------------------------------------------------
# Au repos, les P-states font chuter la fréquence (~1000 MHz) : une lecture à
# l'arrêt est donc trompeuse pour valider un OC (le CPU atteint pourtant bien
# la cible sous charge). On charge brièvement un cœur en arrière-plan, on
# attend ~1 s que les P-states montent, puis on garde le MAX observé sur tous
# les cœurs. Retourne 0 (devient inutilisable) si aucune lecture n'est possible.
measure_cpu_freq() {
    local pid="" freq=0 v=0 loaded=0 f
    if command -v stress-ng &>/dev/null; then
        stress-ng --cpu 1 --timeout 3s --quiet >/dev/null 2>&1 &
        pid=$!; loaded=1
    else
        # Boucle pure en arrière-plan : aucun paquet supplémentaire requis
        ( while :; do :; done ) &
        pid=$!; loaded=1
    fi
    (( loaded )) && sleep 1
    # scaling_cur_freq (kHz) est le plus fidèle ; /proc/cpuinfo en secours
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
        [[ -r "$f" ]] || continue
        v=$(<"$f"); v=$((v / 1000))
        (( v > freq )) && freq=$v
    done
    if [[ "$freq" -eq 0 ]]; then
        freq=$(awk -F: '/^cpu MHz/ {v=$2+0.5; if (v>m) m=v} END {printf "%d", m}' /proc/cpuinfo 2>/dev/null || true)
        [[ -z "$freq" ]] && freq=0
    fi
    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    printf '%s' "$freq"
}

# ------------------------------------------------------------------
# Extraction de fréquence GPU (MHz) depuis une ligne d'état DPM/rocm-smi
# ------------------------------------------------------------------
# Les lignes pp_dpm_sclk sont du format "1: 23Mhz *" : le PREMIER nombre est
# l'index de l'état, PAS la fréquence ! Un grep '[0-9]+' naïf renvoie donc
# l'index (d'où des relevés absurdes comme "2" au lieu de "2000"). On cible le
# nombre accolé à "Mhz"/"MHz" (espace optionnel: rocm-smi écrit "2000 MHz").
sclk_freq_mhz() {
    grep -oE '[0-9]+ ?M[hH]z' | head -1 | tr -dc '0-9'
}

# ------------------------------------------------------------------
# Tension CPU actuelle (mV) mesurée SOUS CHARGE via le SMU (q3/0x36)
# ------------------------------------------------------------------
# Les railes k10temp/amdgpu n'exposent PAS le VID CPU (seuls vddgfx/vddnb pour
# le GPU/NB sont visibles via sensors). La seule source fiable est le SMU :
# le paquet vendorisé bc250_smu_oc fournit déjà l'API. Comme pour la
# fréquence, on charge brièvement un cœur sinon la lecture ne reflète que le
# VID d'économie d'énergie. Retourne vide si illisible (ex: non-root).
measure_cpu_voltage_mv() {
    local pid="" loaded=0 v=""
    if command -v stress-ng &>/dev/null; then
        stress-ng --cpu 1 --timeout 3s --quiet >/dev/null 2>&1 &
        pid=$!; loaded=1
    else
        ( while :; do :; done ) &
        pid=$!; loaded=1
    fi
    (( loaded )) && sleep 1
    v=$(python3 - "${BC250_ROOT}/vendor/bc250_smu_oc" <<'PYEOF' 2>/dev/null || true
import sys
sys.path.insert(0, sys.argv[1])
try:
    from bc250_smu import Bc250Smu
    smu = Bc250Smu(use_flock=True)
    print(int(smu.q3_0x36_get_current_cpu_voltage()))
except Exception:
    raise SystemExit(1)
PYEOF
)
    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    printf '%s' "$v"
}

# ------------------------------------------------------------------
# TESTS INSTANTANÉS (non-bloquants)
# ------------------------------------------------------------------
title "$(t m09_instant_title)"

# 1) CPU Cores
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m09_dry_cpu_cores)"
    report_result "$(t m09_t_cpu_cores_16)" "pass" "[DRY-RUN]"
else
    cpu_threads=$(nproc)
    # 8 cœurs physiques = 16 threads avec SMT. Le déblocage vient soit du
    # logiciel (module 03) soit du BIOS moddé (module 02 : "Unlock CPU cores") :
    # les messages diffèrent donc selon que le BIOS gouverne les cœurs.
    if [[ "$cpu_threads" -eq 16 ]]; then
        if [[ "$BIOS_GOVERN" == "1" ]]; then
            report_result "$(t m09_t_cpu_cores_16)" "pass" "$(t m09_threads_bios_unlocked "$cpu_threads")"
        else
            report_result "$(t m09_t_cpu_cores_16)" "pass" "$(t m09_threads_detected "$cpu_threads")"
        fi
    elif [[ "$cpu_threads" -eq 8 ]]; then
        if [[ "$BIOS_GOVERN" == "1" ]]; then
            report_result "$(t m09_t_cpu_cores_8)" "warn" "$(t m09_threads_bios_not_enabled "$cpu_threads")"
        else
            report_result "$(t m09_t_cpu_cores_8)" "warn" "$(t m09_threads_not_unlocked "$cpu_threads")"
        fi
    else
        report_result "$(t m09_t_cpu_cores)" "fail" "$(t m09_threads_unexpected "$cpu_threads")"
    fi
fi

# 2) CPU Fréquence (mesurée SOUS CHARGE)
# Au repos la fréquence chute (~1000 MHz) via les P-states : ce n'est pas une
# erreur mais l'économie d'énergie normale. On mesure donc le MAX atteint
# pendant une courte charge pour valider l'OC réel.
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m09_dry_cpu_freq "${CPU_FREQ_MHZ:-3850}")"
    report_result "$(t m09_t_cpu_freq_near)" "pass" "[DRY-RUN]"
else
    target_freq="${CPU_FREQ_MHZ:-3850}"
    current_freq_mhz=$(measure_cpu_freq)
    if [[ -n "$current_freq_mhz" && "$current_freq_mhz" -gt 0 ]]; then
        diff=$((current_freq_mhz > target_freq ? current_freq_mhz - target_freq : target_freq - current_freq_mhz))
        if [[ $diff -le 100 ]]; then
            report_result "$(t m09_t_cpu_freq_near)" "pass" "$(t m09_freq_target "$current_freq_mhz" "$target_freq")"
        elif [[ $diff -le 200 ]]; then
            report_result "$(t m09_t_cpu_freq_diff200)" "warn" "$(t m09_freq_target_diff "$current_freq_mhz" "$target_freq" "$diff")"
        else
            report_result "$(t m09_t_cpu_freq_diff_gt200)" "warn" "$(t m09_freq_under_target "$current_freq_mhz" "$target_freq" "$diff")"
        fi
    else
        report_result "$(t m09_t_cpu_freq)" "warn" "$(t m09_cpuinfo_unreadable)"
    fi
fi

# 3) GPU CU actives
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m09_dry_gpu_cu "${GPU_CU_MODE:-full}")"
    report_result "$(t m09_t_gpu_cu_match)" "pass" "[DRY-RUN]"
else
    cu_manager="${BC250_ROOT}/vendor/bc250-cu-live-manager/bc250-cu-live-manager.sh"
    if [[ -x "$cu_manager" ]]; then
        cu_output=$(bash "$cu_manager" status 2>/dev/null || true)
        if echo "$cu_output" | grep -qi "cu.*active\|active.*cu"; then
            # NE PAS faire un grep générique '[0-9]+ CU' : le titre du dashboard
            # contient déjà "BC-250 CU ..." et donnerait 250 au lieu de 40 !
            # On cible la ligne "CUs active & routed : NN/40" du dashboard, avec
            # repli sur "active_cu_number=NN" remonté par le module amdgpu.
            active_cus=$(echo "$cu_output" | grep -oE 'CUs active & routed[^0-9]*[0-9]+' | head -1 | grep -oE '[0-9]+' | tail -1)
            [[ -n "$active_cus" ]] || active_cus=$(echo "$cu_output" | grep -oE 'active_cu_number[^0-9]*[0-9]+' | tail -1 | grep -oE '[0-9]+' | tail -1)
            [[ -n "$active_cus" ]] || active_cus="?"
            target_mode="${GPU_CU_MODE:-full}"
            case "$target_mode" in
                full) expected_cus=40 ;;
                factory) expected_cus=24 ;;
                custom) expected_cus="?" ;;
                *) expected_cus="?" ;;
            esac
            if [[ "$expected_cus" != "?" && "$active_cus" != "?" ]]; then
                if [[ "$active_cus" -eq "$expected_cus" ]]; then
                    report_result "$(t m09_t_gpu_cu_match)" "pass" "$(t m09_cu_active_expected "$active_cus" "$expected_cus")"
                else
                    report_result "$(t m09_t_gpu_cu_mismatch)" "warn" "$(t m09_cu_active_expected_mode "$active_cus" "$expected_cus" "$target_mode")"
                fi
            else
                report_result "$(t m09_t_gpu_cu)" "warn" "$(t m09_cu_detected_mode "$active_cus" "$target_mode")"
            fi
        else
            report_result "$(t m09_t_gpu_cu)" "warn" "$(t m09_cu_parse_fail)"
        fi
    else
        report_result "$(t m09_t_gpu_cu)" "warn" "$(t m09_cu_manager_missing)"
    fi
fi

# 4) Services systemd
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m09_dry_services)"
    report_result "$(t m09_t_service bc250-core-unlock.service)" "pass" "[DRY-RUN]"
    report_result "$(t m09_t_service bc250-smu-oc.service)" "pass" "[DRY-RUN]"
    report_result "$(t m09_t_service cyan-skillfish-governor-smu.service)" "pass" "[DRY-RUN]"
else
    for svc in bc250-core-unlock.service bc250-smu-oc.service cyan-skillfish-governor-smu.service; do
        if [[ "$svc" == "bc250-core-unlock.service" && "$BIOS_GOVERN" == "1" ]]; then
            # Le BIOS moddé gouverne le déblocage des cœurs : le module 03 est
            # sauté et son service logiciel n'est ni installé ni requis.
            report_result "$(t m09_t_service "$svc")" "pass" "$(t m09_svc_bios_governs)"
            continue
        fi
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            report_result "$(t m09_t_service "$svc")" "pass" "$(t m09_svc_active)"
        elif systemctl is-enabled --quiet "$svc" 2>/dev/null; then
            report_result "$(t m09_t_service "$svc")" "warn" "$(t m09_svc_enabled_inactive)"
        else
            report_result "$(t m09_t_service "$svc")" "fail" "$(t m09_svc_inactive)"
        fi
    done
fi

# 5) BIOS VRAM
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m09_dry_vram "${BIOS_TARGET_VRAM_MB:-512}")"
    report_result "$(t m09_t_vram_target 512)" "pass" "[DRY-RUN]"
else
    vram_mb=0
    # Source fiable n°1 : mem_info_vram_total (octets) exposé par amdgpu en
    # sysfs. Ne pas hardcoder card0/card1 : l'index DRM varie selon la plateforme.
    vram_file="$(find_drm_vram_total)"
    if [[ -n "$vram_file" ]]; then
        vram_bytes=$(<"$vram_file")
        if [[ "$vram_bytes" =~ ^[0-9]+$ ]] && ((vram_bytes > 0)); then
            # Convertir octets -> Mo (le BIOS moddé expose la VRAM allouée)
            vram_mb=$((vram_bytes / 1024 / 1024))
        fi
    fi

    # Repli : lspci -v, en localisant le slot PCI (pas d'adresse codée en dur)
    if [[ "$vram_mb" -eq 0 ]]; then
        lspci_bus=$(lspci -nn 2>/dev/null | grep -i '1002:13fe' | cut -d' ' -f1)
        if [[ -n "$lspci_bus" ]]; then
            lspci_output=$(lspci -v -s "$lspci_bus" 2>/dev/null || true)
        else
            lspci_output=$(lspci -v 2>/dev/null | grep -A 20 "VGA compatible controller" | head -25)
        fi
        if echo "$lspci_output" | grep -qi "memory.*512m\|memory.*524288k"; then
            vram_mb=512
        elif echo "$lspci_output" | grep -qi "memory.*8g\|memory.*8192m\|memory.*8388608k"; then
            vram_mb=8192
        else
            # Repli final: dmesg
            dmesg_vram=$(dmesg -T 2>/dev/null | grep -i vram | head -1 || true)
            if echo "$dmesg_vram" | grep -q "512"; then
                vram_mb=512
            elif echo "$dmesg_vram" | grep -q "8192\|8g\|8G"; then
                vram_mb=8192
            fi
        fi
    fi

    target_vram="${BIOS_TARGET_VRAM_MB:-512}"
    if [[ "$vram_mb" -eq "$target_vram" ]]; then
        report_result "$(t m09_t_vram_target "$target_vram")" "pass" "$(t m09_vram_detected "$vram_mb")"
    elif [[ "$vram_mb" -eq 8192 ]]; then
        report_result "$(t m09_t_vram_default)" "warn" "$(t m09_vram_default_msg)"
    elif [[ "$vram_mb" -gt 0 ]]; then
        report_result "$(t m09_t_vram)" "warn" "$(t m09_vram_detected_target "$vram_mb" "$target_vram")"
    else
        report_result "$(t m09_t_vram)" "warn" "$(t m09_vram_unknown)"
    fi
fi

# 6) Températures
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m09_dry_temps)"
    report_result "$(t m09_t_cpu_temp_ok)" "pass" "[DRY-RUN]"
    report_result "$(t m09_t_gpu_temp_ok)" "pass" "[DRY-RUN]"
else
    if command -v sensors &>/dev/null; then
        sensors_output=$(sensors 2>/dev/null || true)
        cpu_temp=0
        gpu_temp=0

        # CPU temp (k10temp). Attention : la valeur est portée par la ligne
        # "Tctl:" et PAS par l'en-tête du bloc (k10temp-pci-00c3), qui ne
        # contient aucune température. Ancrer sur le libellé de mesure.
        cpu_line=$(echo "$sensors_output" | grep -iE '^(Tctl|Tdie|Tccd|Package).*[0-9]+\.[0-9]+°c' | head -1)
        if [[ -n "$cpu_line" ]]; then
            cpu_temp=$(echo "$cpu_line" | grep -oE '[0-9]+\.[0-9]+' | head -1 | awk '{print int($1+0.5)}')
        fi

        # GPU temp (amdgpu) : ligne libellée "edge:"/"junction:" du bloc amdgpu
        gpu_line=$(echo "$sensors_output" | grep -iE '^(edge|junction).*[0-9]+\.[0-9]+°c' | head -1)
        if [[ -n "$gpu_line" ]]; then
            gpu_temp=$(echo "$gpu_line" | grep -oE '[0-9]+\.[0-9]+' | head -1 | awk '{print int($1+0.5)}')
        fi

        if [[ "$cpu_temp" -gt 0 ]]; then
            if [[ "$cpu_temp" -le 85 ]]; then
                report_result "$(t m09_t_cpu_temp_ok)" "pass" "${cpu_temp}°C"
            else
                report_result "$(t m09_t_cpu_temp_high)" "warn" "$(t m09_temp_check_cooling "$cpu_temp")"
            fi
        else
            report_result "$(t m09_t_cpu_temp)" "warn" "$(t m09_temp_not_detected)"
        fi

        if [[ "$gpu_temp" -gt 0 ]]; then
            if [[ "$gpu_temp" -le 80 ]]; then
                report_result "$(t m09_t_gpu_temp_ok)" "pass" "${gpu_temp}°C"
            else
                report_result "$(t m09_t_gpu_temp_high)" "warn" "$(t m09_temp_check_cooling "$gpu_temp")"
            fi
        else
            report_result "$(t m09_t_gpu_temp)" "warn" "$(t m09_temp_not_detected)"
        fi
    else
        report_result "$(t m09_t_temps)" "warn" "$(t m09_sensors_missing)"
    fi
fi

# 7) Voltage CPU (sécurité absolue)
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m09_dry_voltage "${CPU_VID_MV:-1150}")"
    report_result "$(t m09_t_voltage_ok)" "pass" "[DRY-RUN]"
else
    cpu_voltage_mv=0
    voltage_source=""

    # Source fiable : SMU q3/0x36 (VID CPU réel). Le paquet bc250_smu_oc est
    # vendorisé : pas besoin qu'il soit installé via pip (module 05). Mesuré
    # sous charge pour refléter le VID d'OC (au repos le VID chute). Nécessite
    # root (les lectures SMU passent par le config space PCI).
    smu_voltage_mv=$(measure_cpu_voltage_mv)
    if [[ "$smu_voltage_mv" =~ ^[0-9]+$ ]] && ((smu_voltage_mv > 0)); then
        cpu_voltage_mv="$smu_voltage_mv"
        voltage_source="SMU (q3/0x36)"
    fi

    # Fallback: sensors (Vcore)
    if [[ "$cpu_voltage_mv" -eq 0 ]] && command -v sensors &>/dev/null; then
        sensors_output=$(sensors 2>/dev/null || true)
        # Chercher Vcore / in0 / CPU voltage. NE PAS prendre vddgfx/vddnb :
        # ce sont des tensions GPU/NB, pas le VID CPU.
        vcore_line=$(echo "$sensors_output" | grep -iE '(vcore|in0|cpu voltage).*[0-9]+\.[0-9]+' | head -1)
        if [[ -n "$vcore_line" ]]; then
            # sensors donne en Volts (ex: 1.15), convertir en mV
            vcore_v=$(echo "$vcore_line" | grep -oE '[0-9]+\.[0-9]+' | head -1)
            if [[ -n "$vcore_v" ]]; then
                cpu_voltage_mv=$(awk -v v="$vcore_v" 'BEGIN {printf "%d", v * 1000 + 0.5}')
                voltage_source="sensors (Vcore)"
            fi
        fi
    fi

    target_vid="${CPU_VID_MV:-1150}"

    if [[ "$cpu_voltage_mv" -gt 0 ]]; then
        # Seuil dur sécurité : > 1300 mV = FAIL
        if [[ "$cpu_voltage_mv" -gt 1300 ]]; then
            report_result "$(t m09_t_voltage_danger)" "fail" "$(t m09_voltage_danger_msg "$cpu_voltage_mv" "$voltage_source")"
        else
            # Tolérance ±50 mV vs config
            diff=$((cpu_voltage_mv > target_vid ? cpu_voltage_mv - target_vid : target_vid - cpu_voltage_mv))
            if [[ $diff -le 50 ]]; then
                report_result "$(t m09_t_voltage_ok)" "pass" "$(t m09_voltage_ok_msg "$cpu_voltage_mv" "$target_vid" "$voltage_source")"
            else
                report_result "$(t m09_t_voltage_diff)" "warn" "$(t m09_voltage_diff_msg "$cpu_voltage_mv" "$target_vid" "$diff" "$voltage_source")"
            fi
        fi
    else
        report_result "$(t m09_t_voltage)" "warn" "$(t m09_voltage_unreadable)"
    fi
fi

# 8) Fréquence GPU
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m09_dry_gpu_freq "${GPU_FREQ_MHZ:-2000}")"
    report_result "$(t m09_t_gpu_freq_near)" "pass" "[DRY-RUN]"
else
    target_gpu_freq="${GPU_FREQ_MHZ:-2000}"
    current_gpu_freq=0
    top_gpu_freq=0

    # Essayer via pp_dpm_sclk (kernel AMDGPU) — auto-détection du card*
    # (l'index DRM n'est pas toujours card0, ex: card1 quand un IGP est présent)
    dpm_sclk="$(find_drm_sclk)"
    if [[ -n "$dpm_sclk" ]]; then
        # Format typique: lignes "0: 300Mhz", "20: 2000Mhz", l'étoile = état
        # COURANT. Au repos le GPU descend vers l'état bas (~300 MHz) : on
        # valide donc la fréquence MAX atteignable (top state) plutôt que
        # l'état courant au repos, comme pour la fréquence CPU.
        current_line=$(grep '\*' "$dpm_sclk" 2>/dev/null || true)
        top_line=$(grep -E '^[0-9]+:' "$dpm_sclk" 2>/dev/null | tail -1 || true)
        if [[ -n "$current_line" ]]; then
            current_gpu_freq=$(printf '%s\n' "$current_line" | sclk_freq_mhz)
            [[ -n "$current_gpu_freq" ]] || current_gpu_freq=0
        fi
        if [[ -n "$top_line" ]]; then
            top_gpu_freq=$(printf '%s\n' "$top_line" | sclk_freq_mhz)
            [[ -n "$top_gpu_freq" ]] || top_gpu_freq=0
        fi
    fi

    # Fallback: rocm-smi (état courant seulement)
    if [[ "$top_gpu_freq" -eq 0 ]] && command -v rocm-smi &>/dev/null; then
        rocm_output=$(rocm-smi --showclkfrq 2>/dev/null || true)
        # Format typique: "sclk: 2000 MHz" ou similaire
        if echo "$rocm_output" | grep -qi 'sclk'; then
            current_gpu_freq=$(echo "$rocm_output" | grep -i 'sclk' | sed 's/.*://' | sclk_freq_mhz)
            [[ -n "$current_gpu_freq" ]] || current_gpu_freq=0
            top_gpu_freq="$current_gpu_freq"
        fi
    fi

    if [[ "$top_gpu_freq" -gt 0 ]]; then
        diff=$((top_gpu_freq > target_gpu_freq ? top_gpu_freq - target_gpu_freq : target_gpu_freq - top_gpu_freq))
        if [[ $diff -le 100 ]]; then
            report_result "$(t m09_t_gpu_freq_near)" "pass" "$(t m09_gpu_freq_msg "$top_gpu_freq" "$target_gpu_freq" "$current_gpu_freq")"
        else
            report_result "$(t m09_t_gpu_freq_diff)" "warn" "$(t m09_gpu_freq_diff_msg "$top_gpu_freq" "$target_gpu_freq" "$diff" "$current_gpu_freq")"
        fi
    else
        report_result "$(t m09_t_gpu_freq)" "warn" "$(t m09_gpu_freq_unreadable)"
    fi
fi

# ------------------------------------------------------------------
# TESTS DE STABILITÉ (optionnels, avec confirmation)
# ------------------------------------------------------------------
echo
title "$(t m09_stability_title)"

# Durée du stress test
stress_duration=300
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m09_dry_stability "$stress_duration")"
    run_stability="y"
else
    if [[ "${BC250_YES:-0}" == "1" ]]; then
        log "$(t m09_yes_duration)"
    else
        read -rp "$(printf "${C_YELLOW}%s${C_NC}" "$(t m09_duration_prompt)")" duration_choice
        case "$duration_choice" in
            60) stress_duration=60 ;;
            "") stress_duration=300 ;;
            *) stress_duration=300 ;;
        esac
    fi
    read -rp "$(printf "${C_YELLOW}%s${C_NC}" "$(t m09_run_stability_prompt "$stress_duration" "$stress_duration" "$(t common_yn)")")" run_stability
fi

yes_re="$(t common_yes_regex)"
if [[ "$run_stability" =~ $yes_re ]]; then
    # Stabilité CPU
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] stress-ng --cpu $(nproc) --timeout ${stress_duration}s"
        report_result "$(t m09_t_cpu_stability "$stress_duration")" "pass" "[DRY-RUN]"
    else
        if command -v stress-ng &>/dev/null; then
            log "$(t m09_stress_cpu_start "$stress_duration")"
            if stress-ng --cpu "$(nproc)" --timeout "${stress_duration}s" --metrics-brief 2>/dev/null; then
                report_result "$(t m09_t_cpu_stability "$stress_duration")" "pass" "$(t m09_finished_ok)"
            else
                report_result "$(t m09_t_cpu_stability "$stress_duration")" "fail" "$(t m09_failed_unstable)"
            fi
        else
            report_result "$(t m09_t_cpu_stability "$stress_duration")" "warn" "$(t m09_stress_ng_missing)"
        fi
    fi

    # Stabilité GPU
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "$(t m09_dry_furmark "$stress_duration")"
        report_result "$(t m09_t_gpu_stability "$stress_duration")" "pass" "[DRY-RUN]"
    else
        # Détecte à la fois le binaire officiel "FurMark" (archive Geeks3D)
        # et celui de l'AUR "furmark" (minuscule) : ne plus ancrer sur un seul
        # casse.
        gpu_stress_bin=""
        for _cand in FurMark furmark FurMark-gui furmark-gui; do
            if command -v "$_cand" &>/dev/null; then
                gpu_stress_bin="$_cand"
                break
            fi
        done

        # Les arguments de stress dépendent de la MAJEURE de FurMark :
        #   - 1.x (binaire Geeks3D historique)  ->  FurMark -t <secondes>
        #   - 2.x (moteur GeeXLab, ex. 2.10.2)  ->  furmark --demo furmark-vk
        #     (le flag -t a été retiré en 2.x ; le stress Vulkan "furmark-vk"
        #     est celui que MangoHud sait surligner).
        gpu_stress_args=(-t "${stress_duration}")
        if [[ "$("$gpu_stress_bin" --version 2>/dev/null)" == 2.* ]]; then
            gpu_stress_args=(--demo furmark-vk)
            log "$(t m09_furmark_v2_demo)"
        fi

        if [[ -n "$gpu_stress_bin" ]]; then
            # Args de stress selon la MAJEURE de FurMark (le -t a disparu en 2.x :
            # le moteur 2.10 n'expose plus que --demo, avec le stress Vulkan
            # "furmark-vk" — celui que MangoHud sait surligner).
            gpu_stress_args=(-t "${stress_duration}")   # legacy 1.x (Geeks3D)
            if "$gpu_stress_bin" --version 2>/dev/null | grep -qE "^2\.[0-9]+"; then
                gpu_stress_args=(--demo furmark-vk)     # 2.x (GeeXLab engine)
                log "$(t m09_gpu_furmark_vk)"
            fi

            log "$(t m09_furmark_start "$stress_duration")"
            # Jumelage MangoHud : on voit sclk/temp/VRAM en direct pendant le
            # test (module 07 l'installe). Best-effort — FurMark 1.x pur
            # OpenGL peut priver l'overlay d'affichage, mais le stress tourne.
            if graphical_session_env; then
                # Le stress tourne dans la SESSION graphique du vrai
                # utilisateur (pas root sans DISPLAY) : FurMark peut ouvrir
                # son dépôt Vulkan/OpenGL et MangoHud sait le surligner.
                local _sfx_user _sfx_pfx=()
                _sfx_user="${GX_USER:-}"
                [[ -n "$_sfx_user" ]] && _sfx_pfx=(runuser -u "$_sfx_user" -- env "${GX_ENV[@]}")
                if (( GX_DISPLAY_FOUND == -social
                1 )); then
                    if command -v mangohud &>/dev/null; then
                        log "$(t m09_gpu_pair_mangohud)"
                        if "${_sfx_pfx[@]}" mangohud "$gpu_stress_bin" "${gpu_stress_args[@]}" 2>/dev/null; then
                            report_result "$(t m09_t_gpu_stability "$stress_duration")" "pass" "$(t m09_finished_ok)"
                        else
                            report_result "$(t m09_t_gpu_stability "$stress_duration")" "fail" "$(t m09_failed_unstable)"
                        fi
                    else
                        if "${_sfx_pfx[@]}" "$gpu_stress_bin" "${gpu_stress_args[@]}" 2>/dev/null; then
                            report_result "$(t m09_t_gpu_stability "$stress_duration")" "pass" "$(t m09_finished_ok)"
                        else
                            report_result "$(t m09_t_gpu_stability "$stress_duration")" "fail" "$(t m09_failed_unstable)"
                        fi
                    fi
                else
                    # Pas de session graphique détectable (SSH/headless) :
                    # un stress FurMark sans DISPLAY ne peut pas démarrer, ce
                    # n'est PAS une instabilité — on signale un warn, pas un
                    # FAIL.
                    report_result "$(t m09_t_gpu_stability "$stress_duration")" "warn" "$(t m09_no_graphical_session)"
                fi
            else
                report_result "$(t m09_t_gpu_stability "$stress_duration")" "warn" "$(t m09_no_graphical_session)"
            fi
        else
            report_result "$(t m09_t_gpu_stability "$stress_duration")" "warn" "$(t m09_furmark_missing)"
        fi
    fi
else
    log "$(t m09_stability_skipped)"
    report_result "$(t m09_t_cpu_stability "$stress_duration")" "warn" "$(t m09_skipped_user)"
    report_result "$(t m09_t_gpu_stability "$stress_duration")" "warn" "$(t m09_skipped_user)"
fi

# ------------------------------------------------------------------
# RAPPORT FINAL
# ------------------------------------------------------------------
echo
total=$((PASS + FAIL + WARN))
if [[ $total -eq 0 ]]; then
    score=0
else
    score=$(( (PASS * 100) / total ))
fi

if [[ $score -ge 90 ]]; then
    score_label="$(t m09_score_excellent)"; score_color="$C_GREEN"
elif [[ $score -ge 70 ]]; then
    score_label="$(t m09_score_good)"; score_color="$C_YELLOW"
else
    score_label="$(t m09_score_check)"; score_color="$C_RED"
fi

# Encadré : largeur calculée sur le texte SANS codes couleur pour rester
# aligné quelle que soit la langue (les libellés n'ont pas la même longueur).
BOX_W=40
box_rule() { # $1 gauche, $2 droite
    local line=""
    local i
    for ((i = 0; i < BOX_W; i++)); do line+="═"; done
    printf '%s%s%s\n' "$1" "$line" "$2"
}
box_line() { # $1 texte brut (pour la largeur), $2 texte affiché (couleurs)
    local plain="$1" shown="${2:-$1}"
    local pad=$(( BOX_W - 2 - ${#plain} ))
    (( pad < 0 )) && pad=0
    printf '║ %s%*s ║\n' "$shown" "$pad" ''
}
pad_right() { # $1 texte, $2 largeur -> texte complété d'espaces (par caractères)
    local s="$1" w="$2"
    while (( ${#s} < w )); do s+=" "; done
    printf '%s' "$s"
}
LBL_W=16
lbl_pass="$(pad_right "$(t m09_report_passed)" $LBL_W)"
lbl_warn="$(pad_right "$(t m09_report_warnings)" $LBL_W)"
lbl_fail="$(pad_right "$(t m09_report_failures)" $LBL_W)"
lbl_score="$(pad_right "$(t m09_report_score)" $LBL_W)"

box_rule '╔' '╗'
box_line "  $(t m09_report_title)"
box_rule '╠' '╣'
box_line "$(printf '%s: %3d  ✓' "$lbl_pass" "$PASS")" "$(printf "%s: %3d  ${C_GREEN}✓${C_NC}" "$lbl_pass" "$PASS")"
box_line "$(printf '%s: %3d  ⚠' "$lbl_warn" "$WARN")" "$(printf "%s: %3d  ${C_YELLOW}⚠${C_NC}" "$lbl_warn" "$WARN")"
box_line "$(printf '%s: %3d  ✗' "$lbl_fail" "$FAIL")" "$(printf "%s: %3d  ${C_RED}✗${C_NC}" "$lbl_fail" "$FAIL")"
box_rule '╠' '╣'
box_line "$(printf '%s: %3d%%  %s' "$lbl_score" "$score" "$score_label")" "$(printf "%s: %3d%%  ${score_color}%s${C_NC}" "$lbl_score" "$score" "$score_label")"
box_rule '╚' '╝'

# ------------------------------------------------------------------
# RECOMMANDATIONS
# ------------------------------------------------------------------
if [[ $FAIL -gt 0 || $WARN -gt 0 ]]; then
    echo
    title "$(t m09_reco_title)"
    if [[ $FAIL -gt 0 ]]; then
        # Vérifier quels tests ont échoué pour donner des conseils ciblés
        # On ne peut pas facilement tracker quels tests ont échoué sans stocker les noms
        # Donc on donne des conseils génériques basés sur les patterns communs
        t m09_reco_fail
    fi
    if [[ $WARN -gt 0 ]]; then
        t m09_reco_warn
    fi
fi

log "$(t m09_done "$score" "$PASS" "$WARN" "$FAIL")"

# Le code de sortie DOIT refléter les échecs : sans ça, install.sh --all
# rapporte un succès (rc=0) même si des tests matériels ont échoué, puisque
# le rc du script suit par défaut celui de la dernière commande exécutée
# (ici un simple echo), sans rapport avec le compteur FAIL. Cf audit du
# 24/08/2026.
if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
