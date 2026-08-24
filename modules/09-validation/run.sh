#!/usr/bin/env bash
# Module 09 — Validation & Benchmark
# Lance une batterie de tests automatisés pour valider l'état du système après
# installation complète de bc250-beast.
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

require_bc250

title "09 - Validation & Benchmark"

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
            die "Statut invalide pour report_result : $status"
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
        log "[DRY-RUN] Commande : $*"
        return 0
    fi
    "$@"
}

# ------------------------------------------------------------------
# TESTS INSTANTANÉS (non-bloquants)
# ------------------------------------------------------------------
title "Tests instantanés"

# 1) CPU Cores
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] Vérification du nombre de cœurs CPU (attendu : 16 threads / 8 cœurs physiques)"
    report_result "CPU Cores (16 threads / 8 cœurs)" "pass" "[DRY-RUN]"
else
    cpu_threads=$(nproc)
    # 8 cœurs physiques = 16 threads avec SMT
    if [[ "$cpu_threads" -eq 16 ]]; then
        report_result "CPU Cores (16 threads / 8 cœurs)" "pass" "$cpu_threads threads détectés"
    elif [[ "$cpu_threads" -eq 8 ]]; then
        report_result "CPU Cores (8 threads / 4 cœurs)" "warn" "$cpu_threads threads — déblocage 8 cœurs non appliqué (module 03)"
    else
        report_result "CPU Cores" "fail" "$cpu_threads threads — inattendu"
    fi
fi

# 2) CPU Fréquence
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] Vérification de la fréquence CPU (config : ${CPU_FREQ_MHZ:-3850} MHz ±100 MHz)"
    report_result "CPU Fréquence (proche de CPU_FREQ_MHZ)" "pass" "[DRY-RUN]"
else
    target_freq="${CPU_FREQ_MHZ:-3850}"
    # Lire la fréquence actuelle depuis /proc/cpuinfo (première entrée cpu MHz)
    current_freq_mhz=$(awk -F: '/^cpu MHz/ {print $2; exit}' /proc/cpuinfo 2>/dev/null | awk '{print int($1+0.5)}')
    if [[ -n "$current_freq_mhz" && "$current_freq_mhz" -gt 0 ]]; then
        diff=$((current_freq_mhz > target_freq ? current_freq_mhz - target_freq : target_freq - current_freq_mhz))
        if [[ $diff -le 100 ]]; then
            report_result "CPU Fréquence (proche de CPU_FREQ_MHZ)" "pass" "${current_freq_mhz} MHz (cible: ${target_freq} MHz)"
        elif [[ $diff -le 200 ]]; then
            report_result "CPU Fréquence (écart ≤ 200 MHz)" "warn" "${current_freq_mhz} MHz (cible: ${target_freq} MHz, écart: ${diff} MHz)"
        else
            report_result "CPU Fréquence (écart > 200 MHz)" "warn" "${current_freq_mhz} MHz (cible: ${target_freq} MHz, écart: ${diff} MHz)"
        fi
    else
        report_result "CPU Fréquence" "warn" "Impossible de lire /proc/cpuinfo"
    fi
fi

# 3) GPU CU actives
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] Vérification des CU GPU actives via bc250-cu-live-manager (config: ${GPU_CU_MODE:-full})"
    report_result "GPU CU actives (match GPU_CU_MODE)" "pass" "[DRY-RUN]"
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
                    report_result "GPU CU actives (match GPU_CU_MODE)" "pass" "${active_cus} CU actives (attendu: ${expected_cus})"
                else
                    report_result "GPU CU actives (écart vs GPU_CU_MODE)" "warn" "${active_cus} CU actives (attendu: ${expected_cus} pour mode ${target_mode})"
                fi
            else
                report_result "GPU CU actives" "warn" "${active_cus} CU actives détectées (mode config: ${target_mode})"
            fi
        else
            report_result "GPU CU actives" "warn" "Impossible de parser la sortie de bc250-cu-live-manager"
        fi
    else
        report_result "GPU CU actives" "warn" "bc250-cu-live-manager non installé ou non exécutable"
    fi
fi

# 4) Services systemd
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] Vérification des services systemd (bc250-core-unlock, bc250-smu-oc, cyan-skillfish-governor)"
    report_result "Service bc250-core-unlock" "pass" "[DRY-RUN]"
    report_result "Service bc250-smu-oc" "pass" "[DRY-RUN]"
    report_result "Service cyan-skillfish-governor" "pass" "[DRY-RUN]"
else
    for svc in bc250-core-unlock.service bc250-smu-oc cyan-skillfish-governor; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            report_result "Service $svc" "pass" "actif"
        elif systemctl is-enabled --quiet "$svc" 2>/dev/null; then
            report_result "Service $svc" "warn" "activé mais non actif (démarrage ?)"
        else
            report_result "Service $svc" "fail" "inactif / non activé"
        fi
    done
fi

# 5) BIOS VRAM
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] Vérification allocation VRAM BIOS (cible: ${BIOS_TARGET_VRAM_MB:-512} Mo)"
    report_result "BIOS VRAM (512 Mo)" "pass" "[DRY-RUN]"
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
        report_result "BIOS VRAM (${target_vram} Mo)" "pass" "${vram_mb} Mo détectés"
    elif [[ "$vram_mb" -eq 8192 ]]; then
        report_result "BIOS VRAM (8 Go = défaut usine)" "warn" "VRAM à 8 Go (défaut), bascule 512 Mo non appliquée (module 02)"
    elif [[ "$vram_mb" -gt 0 ]]; then
        report_result "BIOS VRAM" "warn" "${vram_mb} Mo détectés (cible: ${target_vram} Mo)"
    else
        report_result "BIOS VRAM" "warn" "Impossible de déterminer l'allocation VRAM"
    fi
fi

# 6) Températures
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] Vérification des températures CPU/GPU via sensors"
    report_result "Température CPU (≤ 85°C)" "pass" "[DRY-RUN]"
    report_result "Température GPU (≤ 80°C)" "pass" "[DRY-RUN]"
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
                report_result "Température CPU (≤ 85°C)" "pass" "${cpu_temp}°C"
            else
                report_result "Température CPU (> 85°C)" "warn" "${cpu_temp}°C — vérifier refroidissement (module 01)"
            fi
        else
            report_result "Température CPU" "warn" "Non détectée via sensors"
        fi

        if [[ "$gpu_temp" -gt 0 ]]; then
            if [[ "$gpu_temp" -le 80 ]]; then
                report_result "Température GPU (≤ 80°C)" "pass" "${gpu_temp}°C"
            else
                report_result "Température GPU (> 80°C)" "warn" "${gpu_temp}°C — vérifier refroidissement (module 01)"
            fi
        else
            report_result "Température GPU" "warn" "Non détectée via sensors"
        fi
    else
        report_result "Température CPU/GPU" "warn" "Commande 'sensors' non disponible (lm-sensors non installé)"
    fi
fi

# 7) Voltage CPU (sécurité absolue)
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] Vérification voltage CPU via bc250_smu_oc ou sensors (seuil dur: 1300 mV, tolérance ±50 mV vs CPU_VID_MV=${CPU_VID_MV:-1150})"
    report_result "Voltage CPU (≤ 1300 mV, tolérance ±50 mV)" "pass" "[DRY-RUN]"
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
            report_result "Voltage CPU (> 1300 mV = DANGER)" "fail" "${cpu_voltage_mv} mV (source: ${voltage_source}) — DÉPASSE LE SEUIL ABSOLU DE SÉCURITÉ"
        else
            # Tolérance ±50 mV vs config
            diff=$((cpu_voltage_mv > target_vid ? cpu_voltage_mv - target_vid : target_vid - cpu_voltage_mv))
            if [[ $diff -le 50 ]]; then
                report_result "Voltage CPU (≤ 1300 mV, tolérance ±50 mV)" "pass" "${cpu_voltage_mv} mV (cible: ${target_vid} mV, source: ${voltage_source})"
            else
                report_result "Voltage CPU (écart > 50 mV vs config)" "warn" "${cpu_voltage_mv} mV (cible: ${target_vid} mV, écart: ${diff} mV, source: ${voltage_source})"
            fi
        fi
    else
        report_result "Voltage CPU" "warn" "Voltage non lisible (bc250_smu_oc, bc250_detect.py, sensors Vcore) — vérifiez manuellement"
    fi
fi

# 8) Fréquence GPU
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] Vérification fréquence GPU via /sys/class/drm/card0/device/pp_dpm_sclk ou rocm-smi (cible: ${GPU_FREQ_MHZ:-2000} MHz ±100 MHz)"
    report_result "Fréquence GPU (proche de GPU_FREQ_MHZ ±100 MHz)" "pass" "[DRY-RUN]"
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
            report_result "Fréquence GPU (proche de GPU_FREQ_MHZ ±100 MHz)" "pass" "${current_gpu_freq} MHz (cible: ${target_gpu_freq} MHz, source: ${gpu_freq_source})"
        else
            report_result "Fréquence GPU (écart > 100 MHz vs config)" "warn" "${current_gpu_freq} MHz (cible: ${target_gpu_freq} MHz, écart: ${diff} MHz, source: ${gpu_freq_source})"
        fi
    else
        report_result "Fréquence GPU" "warn" "Non lisible (pp_dpm_sclk absent, rocm-smi absent) — vérifiez manuellement"
    fi
fi

# ------------------------------------------------------------------
# TESTS DE STABILITÉ (optionnels, avec confirmation)
# ------------------------------------------------------------------
echo
title "Tests de stabilité (optionnels)"

# Durée du stress test
stress_duration=300
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] Tests de stabilité : demande de confirmation simulée = OUI, durée = ${stress_duration}s"
    run_stability="y"
else
    if [[ "${BC250_YES:-0}" == "1" ]]; then
        log "BC250_YES=1 : durée par défaut 300 s (recommandé)."
    else
        read -rp "$(printf "${C_YELLOW}Durée des tests de stabilité : 300 s (recommandé) ou 60 s (rapide) ? [300/60] : ${C_NC}")" duration_choice
        case "$duration_choice" in
            60) stress_duration=60 ;;
            "") stress_duration=300 ;;
            *) stress_duration=300 ;;
        esac
    fi
    read -rp "$(printf "${C_YELLOW}Voulez-vous lancer les tests de stabilité (${stress_duration}s CPU + ${stress_duration}s GPU) ? [y/N] : ${C_NC}")" run_stability
fi

if [[ "$run_stability" =~ ^[Yy]$ ]]; then
    # Stabilité CPU
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] stress-ng --cpu $(nproc) --timeout ${stress_duration}s"
        report_result "Stabilité CPU (stress-ng ${stress_duration}s)" "pass" "[DRY-RUN]"
    else
        if command -v stress-ng &>/dev/null; then
            log "Lancement stress-ng CPU ${stress_duration}s (utilise tous les cœurs)..."
            if stress-ng --cpu "$(nproc)" --timeout "${stress_duration}s" --metrics-brief 2>/dev/null; then
                report_result "Stabilité CPU (stress-ng ${stress_duration}s)" "pass" "Terminé sans erreur"
            else
                report_result "Stabilité CPU (stress-ng ${stress_duration}s)" "fail" "Échec ou interruption — instabilité détectée"
            fi
        else
            report_result "Stabilité CPU (stress-ng ${stress_duration}s)" "warn" "stress-ng non installé (pkg_install stress-ng pour l'ajouter)"
        fi
    fi

    # Stabilité GPU
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] Test GPU FurMark ${stress_duration}s"
        report_result "Stabilité GPU (FurMark ${stress_duration}s)" "pass" "[DRY-RUN]"
    else
        if command -v FurMark &>/dev/null; then
            log "Lancement FurMark GPU ${stress_duration}s..."
            if FurMark -t "${stress_duration}" 2>/dev/null; then
                report_result "Stabilité GPU (FurMark ${stress_duration}s)" "pass" "Terminé sans erreur"
            else
                report_result "Stabilité GPU (FurMark ${stress_duration}s)" "fail" "Échec ou interruption — instabilité détectée"
            fi
        else
            report_result "Stabilité GPU (FurMark ${stress_duration}s)" "warn" "FurMark non installé, test GPU ignoré"
        fi
    fi
else
    log "Tests de stabilité ignorés sur demande utilisateur."
    report_result "Stabilité CPU (stress-ng ${stress_duration}s)" "warn" "Ignoré (choix utilisateur)"
    report_result "Stabilité GPU (FurMark ${stress_duration}s)" "warn" "Ignoré (choix utilisateur)"
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
    score_label="${C_GREEN}EXCELLENT${C_NC}"
elif [[ $score -ge 70 ]]; then
    score_label="${C_YELLOW}BON${C_NC}"
else
    score_label="${C_RED}À VÉRIFIER${C_NC}"
fi

cat <<EOF
╔══════════════════════════════════════╗
║   RAPPORT DE VALIDATION BC-250       ║
╠══════════════════════════════════════╣
║  Tests réussis :  ${PASS}  ${C_GREEN}✓${C_NC}               ║
║  Avertissements:  ${WARN}  ${C_YELLOW}⚠${C_NC}               ║
║  Échecs        :  ${FAIL}  ${C_RED}✗${C_NC}               ║
╠══════════════════════════════════════╣
║  Score global  :  ${score}%  ${score_label}   ║
╚══════════════════════════════════════╝
EOF

# ------------------------------------------------------------------
# RECOMMANDATIONS
# ------------------------------------------------------------------
if [[ $FAIL -gt 0 || $WARN -gt 0 ]]; then
    echo
    title "Recommandations"
    if [[ $FAIL -gt 0 ]]; then
        # Vérifier quels tests ont échoué pour donner des conseils ciblés
        # On ne peut pas facilement tracker quels tests ont échoué sans stocker les noms
        # Donc on donne des conseils génériques basés sur les patterns communs
        echo "  • Des tests ont échoué. Vérifiez les modules correspondants :"
        echo "    - Si cœurs CPU non débloqués       → relancez le module 03"
        echo "    - Si services systemd inactifs     → journalctl -u <service> pour diagnostiquer"
        echo "    - Si fréquence CPU instable        → revoyez module 05 (CPU OC) + stress test"
        echo "    - Si VRAM non basculée à 512 Mo    → refaites le module 02 (BIOS/UEFI)"
    fi
    if [[ $WARN -gt 0 ]]; then
        echo "  • Des avertissements ont été émis :"
        echo "    - Températures élevées             → vérifiez le refroidissement (module 01)"
        echo "    - GPU CU / Fréquence non conformes → revoyez modules 04, 05, 06"
        echo "    - Outils manquants (sensors, FurMark, stress-ng)"
        echo "      → installez-les via votre gestionnaire de paquets"
    fi
fi

log "Module 09 terminé (Score: ${score}% — ${PASS}P/${WARN}W/${FAIL}F)."

# Le code de sortie DOIT refléter les échecs : sans ça, install.sh --all
# rapporte un succès (rc=0) même si des tests matériels ont échoué, puisque
# le rc du script suit par défaut celui de la dernière commande exécutée
# (ici un simple echo), sans rapport avec le compteur FAIL. Cf audit du
# 24/08/2026.
if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0