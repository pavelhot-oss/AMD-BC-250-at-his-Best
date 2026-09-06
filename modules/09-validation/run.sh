#!/usr/bin/env bash
# Module 09 — Validation & Benchmark
# Lance une batterie de tests automatisés pour valider l'état du système après
# installation complète de bc250-beast.
set -uo pipefail
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
# TESTS INSTANTANÉS (non-bloquants)
# ------------------------------------------------------------------
title "$(t m09_instant_title)"

# 1) CPU Cores
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m09_dry_cpu_cores)"
    report_result "$(t m09_t_cpu_cores_16)" "pass" "[DRY-RUN]"
else
    cpu_threads=$(nproc)
    # 8 cœurs physiques = 16 threads avec SMT
    if [[ "$cpu_threads" -eq 16 ]]; then
        report_result "$(t m09_t_cpu_cores_16)" "pass" "$(t m09_threads_detected "$cpu_threads")"
    elif [[ "$cpu_threads" -eq 8 ]]; then
        report_result "$(t m09_t_cpu_cores_8)" "warn" "$(t m09_threads_not_unlocked "$cpu_threads")"
    else
        report_result "$(t m09_t_cpu_cores)" "fail" "$(t m09_threads_unexpected "$cpu_threads")"
    fi
fi

# 2) CPU Fréquence
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "$(t m09_dry_cpu_freq "${CPU_FREQ_MHZ:-3850}")"
    report_result "$(t m09_t_cpu_freq_near)" "pass" "[DRY-RUN]"
else
    target_freq="${CPU_FREQ_MHZ:-3850}"
    # Lire la fréquence actuelle depuis /proc/cpuinfo (première entrée cpu MHz)
    current_freq_mhz=$(awk -F: '/^cpu MHz/ {print $2; exit}' /proc/cpuinfo 2>/dev/null | awk '{print int($1+0.5)}')
    if [[ -n "$current_freq_mhz" && "$current_freq_mhz" -gt 0 ]]; then
        diff=$((current_freq_mhz > target_freq ? current_freq_mhz - target_freq : target_freq - current_freq_mhz))
        if [[ $diff -le 100 ]]; then
            report_result "$(t m09_t_cpu_freq_near)" "pass" "$(t m09_freq_target "$current_freq_mhz" "$target_freq")"
        elif [[ $diff -le 200 ]]; then
            report_result "$(t m09_t_cpu_freq_diff200)" "warn" "$(t m09_freq_target_diff "$current_freq_mhz" "$target_freq" "$diff")"
        else
            report_result "$(t m09_t_cpu_freq_diff_gt200)" "warn" "$(t m09_freq_target_diff "$current_freq_mhz" "$target_freq" "$diff")"
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
            # Parser le nombre de CU actives (format typique: "40 CU active" ou similaire)
            active_cus=$(echo "$cu_output" | grep -oE '[0-9]+\s*CU' | head -1 | grep -oE '[0-9]+' || echo "?")
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
    report_result "$(t m09_t_service bc250-core-unlock)" "pass" "[DRY-RUN]"
    report_result "$(t m09_t_service bc250-smu-oc)" "pass" "[DRY-RUN]"
    report_result "$(t m09_t_service cyan-skillfish-governor)" "pass" "[DRY-RUN]"
else
    for svc in bc250-core-unlock.service bc250-smu-oc cyan-skillfish-governor; do
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
    # Essayer via lspci -v (cherche Memory derrière le device VGA)
    lspci_output=$(lspci -v -s 0000:05:00.0 2>/dev/null || lspci -v 2>/dev/null | grep -A 20 "VGA compatible controller" | head -25)
    if echo "$lspci_output" | grep -qi "memory.*512m\|memory.*524288k"; then
        vram_mb=512
    elif echo "$lspci_output" | grep -qi "memory.*8g\|memory.*8192m\|memory.*8388608k"; then
        vram_mb=8192
    else
        # Fallback: dmesg
        dmesg_vram=$(dmesg -T 2>/dev/null | grep -i vram | head -1 || true)
        if echo "$dmesg_vram" | grep -q "512"; then
            vram_mb=512
        elif echo "$dmesg_vram" | grep -q "8192\|8g\|8G"; then
            vram_mb=8192
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

        # CPU temp (k10temp ou similar)
        cpu_line=$(echo "$sensors_output" | grep -iE '^(k10temp|cpu|package).*[0-9]+\.[0-9]+°c' | head -1)
        if [[ -n "$cpu_line" ]]; then
            cpu_temp=$(echo "$cpu_line" | grep -oE '[0-9]+\.[0-9]+' | head -1 | awk '{print int($1+0.5)}')
        fi

        # GPU temp (amdgpu)
        gpu_line=$(echo "$sensors_output" | grep -iE '^(amdgpu|edge|junction).*[0-9]+\.[0-9]+°c' | head -1)
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

    # Essayer via bc250_smu_oc (vendor) ou bc250_detect.py
    smu_oc="${BC250_ROOT}/vendor/bc250_smu_oc/bc250_smu_oc"
    detect_py="${BC250_ROOT}/vendor/bc250_smu_oc/bc250_detect.py"
    if [[ -x "$smu_oc" ]]; then
        # bc250_smu_oc peut sortir le voltage actuel (format dépend de l'outil)
        smu_output=$("$smu_oc" --get-vid 2>/dev/null || "$smu_oc" status 2>/dev/null || true)
        # Chercher un pattern type "VID: 1150" ou "voltage: 1150" ou "1150 mV"
        if echo "$smu_output" | grep -qE '(VID|voltage|mV)'; then
            cpu_voltage_mv=$(echo "$smu_output" | grep -oE '[0-9]{4}' | head -1 || echo 0)
            voltage_source="bc250_smu_oc"
        fi
    elif [[ -f "$detect_py" ]]; then
        py_output=$(python3 "$detect_py" --voltage 2>/dev/null || python3 "$detect_py" 2>/dev/null || true)
        if echo "$py_output" | grep -qE '[0-9]{4}'; then
            cpu_voltage_mv=$(echo "$py_output" | grep -oE '[0-9]{4}' | head -1 || echo 0)
            voltage_source="bc250_detect.py"
        fi
    fi

    # Fallback: sensors (Vcore)
    if [[ "$cpu_voltage_mv" -eq 0 ]] && command -v sensors &>/dev/null; then
        sensors_output=$(sensors 2>/dev/null || true)
        # Chercher Vcore / in0 / CPU voltage
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
    gpu_freq_source=""

    # Essayer via pp_dpm_sclk (kernel AMDGPU)
    dpm_sclk="/sys/class/drm/card0/device/pp_dpm_sclk"
    if [[ -r "$dpm_sclk" ]]; then
        # Format typique: lignes avec "0: 300Mhz", "1: 2000Mhz *", l'étoile = actuel
        current_line=$(grep '\*' "$dpm_sclk" 2>/dev/null || true)
        if [[ -n "$current_line" ]]; then
            current_gpu_freq=$(echo "$current_line" | grep -oE '[0-9]+' | head -1 || echo 0)
            gpu_freq_source="pp_dpm_sclk"
        fi
    fi

    # Fallback: rocm-smi
    if [[ "$current_gpu_freq" -eq 0 ]] && command -v rocm-smi &>/dev/null; then
        rocm_output=$(rocm-smi --showclkfrq 2>/dev/null || true)
        # Format typique: "sclk: 2000 MHz" ou similaire
        if echo "$rocm_output" | grep -qi 'sclk'; then
            current_gpu_freq=$(echo "$rocm_output" | grep -i 'sclk' | grep -oE '[0-9]+' | head -1 || echo 0)
            gpu_freq_source="rocm-smi"
        fi
    fi

    if [[ "$current_gpu_freq" -gt 0 ]]; then
        diff=$((current_gpu_freq > target_gpu_freq ? current_gpu_freq - target_gpu_freq : target_gpu_freq - current_gpu_freq))
        if [[ $diff -le 100 ]]; then
            report_result "$(t m09_t_gpu_freq_near)" "pass" "$(t m09_gpu_freq_msg "$current_gpu_freq" "$target_gpu_freq" "$gpu_freq_source")"
        else
            report_result "$(t m09_t_gpu_freq_diff)" "warn" "$(t m09_gpu_freq_diff_msg "$current_gpu_freq" "$target_gpu_freq" "$diff" "$gpu_freq_source")"
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
        if command -v FurMark &>/dev/null; then
            log "$(t m09_furmark_start "$stress_duration")"
            if FurMark -t "${stress_duration}" 2>/dev/null; then
                report_result "$(t m09_t_gpu_stability "$stress_duration")" "pass" "$(t m09_finished_ok)"
            else
                report_result "$(t m09_t_gpu_stability "$stress_duration")" "fail" "$(t m09_failed_unstable)"
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
