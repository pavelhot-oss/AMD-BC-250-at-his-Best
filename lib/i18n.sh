#!/usr/bin/env bash
# lib/i18n.sh — minimal message catalog for bc250-beast (en / fr).
# Sourced by lib/common.sh, do not execute directly.
#
# Usage in scripts:
#   t <key> [printf args...]     prints the translated string + newline
#   "$(t <key> ...)"             same, without the trailing newline
#
# Catalogs live in locale/<lang>.sh as   MSG[key]="..."   lines.
# English is always loaded first as the fallback, then the selected
# language overlays it, so a key missing from fr.sh shows up in English
# instead of breaking. Values are printf formats: use %s for arguments
# and %% for a literal percent sign.
#
# Language resolution (first match wins):
#   1. --lang <code> on the command line (install.sh / uninstall.sh)
#   2. BC250_LANG environment variable
#   3. UI_LANG in config/bc250-beast.conf
#   4. LC_ALL / LC_MESSAGES / LANG of the current session
#   5. English
#
# Run tools/check-i18n.sh to validate the catalogs against the scripts.

I18N_SUPPORTED="en fr"
I18N_DEFAULT="en"
I18N_LANG=""
I18N_EXPLICIT=0          # 1 when the language came from --lang / BC250_LANG
declare -gA MSG=()

i18n_is_supported() { [[ " ${I18N_SUPPORTED} " == *" ${1:-} "* ]]; }

# Guess the language from the session locale. Anything that is not French
# falls back to English (the project's primary language).
i18n_detect() {
    local l="${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}"
    case "${l,,}" in
        fr*) echo "fr" ;;
        *)   echo "${I18N_DEFAULT}" ;;
    esac
}

# Load a catalog. Returns 1 (and leaves the current catalog alone) if the
# language is unknown or its file is missing.
i18n_load() {
    local lang="${1:-}"
    i18n_is_supported "$lang" || return 1
    [[ -f "${BC250_ROOT}/locale/${lang}.sh" ]] || return 1
    MSG=()
    # shellcheck disable=SC1091
    source "${BC250_ROOT}/locale/${I18N_DEFAULT}.sh"
    if [[ "$lang" != "${I18N_DEFAULT}" ]]; then
        # shellcheck disable=SC1090
        source "${BC250_ROOT}/locale/${lang}.sh"
    fi
    I18N_LANG="$lang"
    export BC250_LANG="$lang"
    return 0
}

# Explicit selection (CLI flag, menu). Returns 1 on an unknown code.
i18n_set() {
    i18n_load "${1:-}" || return 1
    I18N_EXPLICIT=1
    return 0
}

# Called once when lib/common.sh is sourced.
i18n_init() {
    local lang="${BC250_LANG:-}"
    if [[ -n "$lang" ]]; then
        I18N_EXPLICIT=1
    else
        lang="$(i18n_detect)"
    fi
    if ! i18n_load "$lang"; then
        i18n_load "${I18N_DEFAULT}"
        warn "$(t i18n_invalid "$lang")"
    fi
}

# Look up a key and format it. Unknown keys are printed as ??key?? so they
# are visible in the output (tools/check-i18n.sh catches them statically).
t() {
    local key="${1:-}"; shift || true
    local fmt
    if [[ -n "${MSG[$key]+x}" ]]; then
        fmt="${MSG[$key]}"
    else
        fmt="??${key}??"
    fi
    # shellcheck disable=SC2059
    printf -- "${fmt}\n" "$@"
}

# Interactive chooser, deliberately bilingual since we don't know the
# user's language yet. Returns 1 if no valid choice was made.
i18n_prompt_language() {
    local choice
    echo
    echo "  1) English"
    echo "  2) Français"
    echo
    read -rp "Language / Langue [1-2]: " choice
    case "$choice" in
        1) i18n_set en ;;
        2) i18n_set fr ;;
        *) return 1 ;;
    esac
    log "$(t i18n_switched "$I18N_LANG")"
}

# Persist the choice as UI_LANG="xx" in the config file (created if the
# line is missing). Returns 1 if the config file does not exist yet.
i18n_save_to_config() {
    local lang="${1:-$I18N_LANG}" file="${2:-$CONFIG_FILE}"
    [[ -f "$file" ]] || return 1
    if grep -qE '^[[:space:]]*(export[[:space:]]+)?UI_LANG=' "$file"; then
        sed -i -E "s|^([[:space:]]*(export[[:space:]]+)?UI_LANG=).*|\1\"${lang}\"|" "$file"
    else
        {
            echo
            echo "# Interface language / Langue de l'interface (en|fr)"
            echo "UI_LANG=\"${lang}\""
        } >> "$file"
    fi
}
