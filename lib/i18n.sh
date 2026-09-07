#!/usr/bin/env bash
# lib/i18n.sh — minimal message catalog for bc250-beast.
# Sourced by lib/common.sh, do not execute directly.
#
# Usage in scripts:
#   t <key> [printf args...]     prints the translated string + newline
#   "$(t <key> ...)"             same, without the trailing newline
#
# Catalogs live in locale/<code>.sh as   MSG[key]="..."   lines, one file
# per language, the file name being the code (en, fr, de, pt, ...). The
# list of available languages IS the list of files: to add a language,
# copy locale/en.sh to locale/<code>.sh, translate every value, set
# MSG[lang_name] to the language's own name, and run tools/check-i18n.sh.
# Nothing else needs editing: the chooser, --lang validation and locale
# auto-detection all read the directory.
#
# English is always loaded first as the fallback, then the selected
# language overlays it, so a key missing from a catalog shows up in
# English instead of breaking. Values are printf formats: use %s for
# arguments and %% for a literal percent sign.
#
# Language resolution (first match wins):
#   1. --lang <code> on the command line (install.sh / uninstall.sh)
#   2. BC250_LANG environment variable
#   3. UI_LANG in config/bc250-beast.conf
#   4. LC_ALL / LC_MESSAGES / LANG of the current session (pt_BR -> pt_br
#      if that file exists, else pt, else English)
#   5. English

I18N_DEFAULT="en"
I18N_LANG=""
I18N_EXPLICIT=0          # 1 when the language came from --lang / BC250_LANG
declare -gA MSG=()

# A code is valid when it is a plain lowercase token and its file exists
# (the pattern also keeps --lang from reaching outside locale/).
i18n_is_supported() {
    [[ "${1:-}" =~ ^[a-z]{2,3}(_[a-z0-9]+)?$ ]] && [[ -f "${BC250_ROOT}/locale/${1}.sh" ]]
}

# Space-separated codes: English first, then the rest alphabetically.
i18n_supported() {
    local f code codes=()
    for f in "${BC250_ROOT}"/locale/*.sh; do
        [[ -f "$f" ]] || continue
        code="${f##*/}"; code="${code%.sh}"
        [[ "$code" == "$I18N_DEFAULT" ]] && continue
        i18n_is_supported "$code" && codes+=("$code")
    done
    printf '%s' "$I18N_DEFAULT"
    (( ${#codes[@]} )) && printf ' %s' "${codes[@]}"
    echo
}

# The language's own name, read from its catalog (falls back to the code).
i18n_lang_name() {
    local code="${1:-}" name=""
    if [[ "$code" == "$I18N_LANG" && -n "${MSG[lang_name]+x}" ]]; then
        name="${MSG[lang_name]}"
    elif i18n_is_supported "$code"; then
        name="$(bash -c 'source "$1" 2>/dev/null && printf "%s" "${MSG[lang_name]-}"' _ "${BC250_ROOT}/locale/${code}.sh" 2>/dev/null)"
    fi
    printf '%s' "${name:-$code}"
}

# Guess the language from the session locale: try the full code (pt_br),
# then the short one (pt), else English.
i18n_detect() {
    local l="${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}"
    l="${l%%.*}"; l="${l%%@*}"; l="${l,,}"
    local short="${l%%_*}"
    if i18n_is_supported "$l"; then
        echo "$l"
    elif i18n_is_supported "$short"; then
        echo "$short"
    else
        echo "${I18N_DEFAULT}"
    fi
}

# Load a catalog. Returns 1 (and leaves the current catalog alone) if the
# code is unknown.
i18n_load() {
    local lang="${1:-}"
    i18n_is_supported "$lang" || return 1
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
        warn "$(t i18n_invalid "$lang" "$(i18n_supported)")"
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

# Interactive chooser built from the catalogs on disk, showing each
# language's own name so it is readable before any language is chosen.
# Returns 1 if no valid choice was made.
i18n_prompt_language() {
    local codes=() code i=0 choice
    read -ra codes <<< "$(i18n_supported)"
    echo
    for code in "${codes[@]}"; do
        i=$((i+1))
        printf '  %d) %s (%s)\n' "$i" "$(i18n_lang_name "$code")" "$code"
    done
    echo
    read -rp "Language [1-${#codes[@]}]: " choice
    [[ "$choice" =~ ^[0-9]+$ ]] || return 1
    (( choice >= 1 && choice <= ${#codes[@]} )) || return 1
    i18n_set "${codes[$((choice-1))]}" || return 1
    log "$(t i18n_switched "$(i18n_lang_name "$I18N_LANG")" "$I18N_LANG")"
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
            echo "# Interface language: a code matching a file in locale/ (en, fr, ...)"
            echo "UI_LANG=\"${lang}\""
        } >> "$file"
    fi
}
