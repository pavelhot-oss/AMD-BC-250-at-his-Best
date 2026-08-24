#!/usr/bin/env bash
# Module 06 — Overclock GPU via le gouverneur cyan-skillfish.
# Ce module gère le cycle de vie complet : clone, build Rust, et configuration.
set -uo pipefail
source "${BC250_ROOT}/lib/common.sh"

title "06 - Overclock GPU (cyan-skillfish-governor)"
require_root
require_bc250

if [[ -f "${BC250_ROOT}/logs/.cooling_power_confirmed" ]]; then
    :
else
    warn "Le module 01 (refroidissement/alimentation) n'a pas été confirmé."
    confirm "Continuer quand même ?" || exit 1
fi

# ------------------------------------------------------------------
# Vérification des dépendances de build (git, make, cargo, pkg-config, libudev)
# ------------------------------------------------------------------
check_build_deps() {
    local missing=()
    for cmd in git make cargo pkg-config; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    # libudev : header requis pour la compilation (check pkg-config commun à toutes les familles)
    pkg-config --exists libudev 2>/dev/null || missing+=("libudev (pkg-config)")

    if [[ ${#missing[@]} -gt 0 ]]; then
        err "Dépendances de build manquantes :"
        for m in "${missing[@]}"; do
            echo "  ❌ $m"
        done
        echo
        local distro; distro="$(detect_distro)"
        case "$distro" in
            arch|cachyos)
                echo "Installez avec :"
                echo "  sudo pacman -S git base-devel rust pkgconf"
                echo "  # libudev est fourni par systemd sur Arch/CachyOS, pas de paquet séparé"
                ;;
            bazzite-ostree|fedora-ostree)
                echo "Installez avec :"
                echo "  sudo rpm-ostree install rust cargo systemd-devel"
                warn "Environnement de build actif après reboot (système immutable rpm-ostree)"
                ;;
            fedora)
                echo "Installez avec :"
                echo "  sudo dnf install git make cargo pkgconf systemd-devel"
                ;;
            debian|ubuntu)
                echo "Installez avec :"
                echo "  sudo apt-get update && sudo apt-get install git build-essential cargo pkg-config libudev-dev"
                ;;
            *)
                echo "Distribution non reconnue ($distro). Installez manuellement : git, make, cargo, pkg-config, libudev headers."
                ;;
        esac
        return 1
    fi
    log "Toutes les dépendances de build sont présentes."
    return 0
}

if ! check_build_deps; then
    exit 1
fi

# ------------------------------------------------------------------
# Clone / mise à jour du dépôt
# ------------------------------------------------------------------
REPO_DIR="/tmp/bc250-beast-build/cyan-skillfish-governor"
mkdir -p "$(dirname "$REPO_DIR")"
if [[ ! -d "$REPO_DIR" ]]; then
    log "Clonage de cyan-skillfish-governor (branche smu)..."
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] git clone --branch smu https://github.com/filippor/cyan-skillfish-governor.git $REPO_DIR"
    else
        git clone --branch smu https://github.com/filippor/cyan-skillfish-governor.git "$REPO_DIR"
    fi
else
    log "Dépôt déjà présent, mise à jour..."
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] git -C $REPO_DIR pull"
    else
        git -C "$REPO_DIR" pull || warn "Échec du pull, on continue avec la copie locale existante."
    fi
fi

# ------------------------------------------------------------------
# Compilation (cargo build --release)
# ------------------------------------------------------------------
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] cargo build --release dans $REPO_DIR"
else
    log "Compilation du gouverneur (cargo build --release)..."
    cd "$REPO_DIR"
    cargo build --release || die "Échec de la compilation cargo. Vérifiez les erreurs ci-dessus."
    log "Compilation réussie. Binaire : $REPO_DIR/target/release/cyan-skillfish-governor"
fi

# ------------------------------------------------------------------
# Configuration (inchangé par rapport à l'original)
# ------------------------------------------------------------------
cat <<EOF

⚠️  Le binaire est compilé. Suivez le README du dépôt pour l'installation
    exacte (service systemd, chemins) qui peut évoluer :
        ${REPO_DIR}/README.md
    Une fois le binaire/service installés par le dépôt lui-même, revenez
    ici pour la configuration.

EOF

if ! confirm "Le gouverneur est installé (binaire + service systemd présents), continuer la configuration ?"; then
    warn "Configuration reportée. Relancez ce module une fois l'installation du gouverneur terminée."
    exit 0
fi

CONF_DIR="/etc/cyan-skillfish-governor"
CONF_FILE="${CONF_DIR}/config.toml"

TARGET_FREQ="${GPU_FREQ_MHZ:-2000}"
TARGET_TEMP="${GPU_TEMP_TARGET_C:-85}"
TARGET_VOLT="${GPU_VOLT_MV:-}"

log "Génération de ${CONF_FILE} (courbe idle -> cible, température cible ${TARGET_TEMP}°C)..."

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log "[DRY-RUN] mkdir -p $CONF_DIR"
    log "[DRY-RUN] Écriture de $CONF_FILE :"
    cat <<EOF
# Généré par bc250-beast — module 06
# Réglages par défaut amont potentiellement instables : tester manuellement
# avant activation au boot.

target-temperature = ${TARGET_TEMP}

[[safe-points]]
frequency = 350
voltage = 700

[[safe-points]]
frequency = ${TARGET_FREQ}
EOF
    if [[ -n "$TARGET_VOLT" ]]; then
        echo "voltage = ${TARGET_VOLT}"
    else
        echo "# voltage non spécifié dans la config -> vérifiez la valeur par défaut du gouverneur"
    fi
else
    mkdir -p "$CONF_DIR"
    {
        echo "# Généré par bc250-beast — module 06"
        echo "# Réglages par défaut amont potentiellement instables : tester manuellement"
        echo "# avant activation au boot."
        echo
        echo "target-temperature = ${TARGET_TEMP}"
        echo
        echo "[[safe-points]]"
        echo "frequency = 350"
        echo "voltage = 700"
        echo
        echo "[[safe-points]]"
        echo "frequency = ${TARGET_FREQ}"
        if [[ -n "$TARGET_VOLT" ]]; then
            echo "voltage = ${TARGET_VOLT}"
        else
            echo "# voltage non spécifié dans la config -> vérifiez la valeur par défaut du gouverneur"
        fi
    } > "$CONF_FILE"
    log "Fichier écrit : $CONF_FILE"
    cat "$CONF_FILE"
fi

cat <<EOF

Progression recommandée par Old Lamer :
  1500 MHz (stock) -> 2000 MHz (palier facile, ~10%+ au FurMark)
  -> valider CPU à 3.85 GHz (module 05) -> pousser le GPU plus loin
  UNIQUEMENT si le refroidissement suit (watercooling: jusqu'à ~2.4GHz
  rapporté, ~360W / 30A, d'où l'importance des connecteurs Molex
  additionnels du module 01).

⚠️  IMPORTANT : testez ce fichier de config MANUELLEMENT (démarrage du
    service en avant-plan / à la main) avant de l'activer au boot.
    N'activez PAS le service automatiquement depuis ce script.
EOF

if confirm "Redémarrer maintenant le service du gouverneur pour appliquer la config testée ?"; then
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log "[DRY-RUN] systemctl restart cyan-skillfish-governor-smu"
    else
        systemctl restart cyan-skillfish-governor-smu 2>/dev/null \
            || warn "Le nom exact du service peut différer selon la version du dépôt — vérifiez avec 'systemctl list-units | grep -i cyan'."
    fi
fi

warn "Une fois la stabilité confirmée manuellement, activez la persistance vous-même avec :"
echo "    sudo systemctl enable --now cyan-skillfish-governor-smu"

log "Le dépôt amont (branche smu) fournit son propre service systemd."
log "Consultez ${REPO_DIR}/README.md pour la procédure d'installation exacte."