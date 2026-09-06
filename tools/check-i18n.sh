#!/usr/bin/env bash
# tools/check-i18n.sh — validates the bc250-beast message catalogs.
#
# Checks (errors fail the run, warnings don't):
#   E0  runtime lookup: lib/common.sh + i18n_load actually resolve a key
#       for every locale (catches scoping bugs a plain source can't see)
#   E1  every locale file loads (bash -n + source) and defines MSG
#   E2  same key set in every locale (missing / extra keys)
#   E3  no duplicate key inside a locale file
#   E4  same number of %s placeholders per key across locales
#   E5  no stray '%' (anything other than %s or %%) in a value
#   E6  every  t <key>  /  $(t <key>  call in the scripts has a key in en.sh
#   E7  every  t  call passes as many arguments as the key has %s
#       (call sites spanning several lines are skipped with a note)
#   E8  config examples (.example / .example.<lang>) declare the same
#       variables with the same values
#   W1  keys defined but never referenced by any script
#   W2  values identical in en and another locale (possibly untranslated),
#       except for the allowlist below (URLs, product names, format-only)
#   W3  English values containing French-only accented letters
#
# Usage:  tools/check-i18n.sh [--quiet]     exit 0 = OK, 1 = errors found
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCALE_DIR="${ROOT}/locale"
BASE="en"
QUIET=0
[[ "${1:-}" == "--quiet" ]] && QUIET=1

ERRORS=0
WARNINGS=0
err()  { ERRORS=$((ERRORS+1));   printf '  \033[0;31m[E]\033[0m %s\n' "$*"; }
warn() { WARNINGS=$((WARNINGS+1)); (( QUIET )) || printf '  \033[1;33m[W]\033[0m %s\n' "$*"; }
info() { (( QUIET )) || printf '\033[0;36m==\033[0m %s\n' "$*"; }
ok()   { (( QUIET )) || printf '  \033[0;32m[ok]\033[0m %s\n' "$*"; }

# Keys whose value is legitimately the same in every language.
SAME_OK_REGEX='^(m09_title|m09_score_excellent|inst_menu_lang_opt|m08_lbl_discord|m08_lbl_telegram|m08_lbl_smp|m09_t_service|m09_t_vram|m09_t_cpu_cores|m09_report_title|inst_status_threads|inst_status_zswap|m00_cpu)$'

# Scripts that may call t(): everything except the catalogs, this tool and vendor/
mapfile -t SCRIPTS < <(cd "$ROOT" && find . -path ./vendor -prune -o -path ./.git -prune -o -path ./locale -prune -o -path ./tools -prune -o -name '*.sh' -print | sort)

# ------------------------------------------------------------------
# Load every catalog into its own associative array
# ------------------------------------------------------------------
mapfile -t LANGS < <(cd "$LOCALE_DIR" && ls *.sh | sed 's/\.sh$//' | sort)
[[ " ${LANGS[*]} " == *" ${BASE} "* ]] || { err "base catalog ${BASE}.sh not found in ${LOCALE_DIR}"; exit 1; }

info "Locales: ${LANGS[*]} (base: ${BASE})"
declare -A KEYS_OF   # lang -> newline-separated key list
declare -A VAL       # "lang|key" -> value

for lang in "${LANGS[@]}"; do
    f="${LOCALE_DIR}/${lang}.sh"
    if ! bash -n "$f" 2>/dev/null; then err "E1 ${lang}.sh: bash syntax error"; continue; fi
    # E3: duplicate keys (textual check, before sourcing collapses them)
    dups=$(grep -oE '^MSG\[[a-z0-9_]+\]' "$f" | sort | uniq -d | tr -d '[]' | sed 's/^MSG//')
    [[ -n "$dups" ]] && err "E3 ${lang}.sh: duplicate keys: $(echo "$dups" | tr '\n' ' ')"
    # source in a subshell and dump key<TAB>value with newlines escaped
    dump=$(bash -c 'set -u; source "$1" || exit 9; [[ "$(declare -p MSG 2>/dev/null)" == "declare -A"* ]] || exit 8
        for k in "${!MSG[@]}"; do v="${MSG[$k]}"; v="${v//\\/\\\\}"; v="${v//$'"'"'\n'"'"'/\\n}"; printf "%s\t%s\n" "$k" "$v"; done' _ "$f" 2>&1)
    rc=$?
    if (( rc != 0 )); then err "E1 ${lang}.sh: does not load cleanly (rc=$rc): $(echo "$dump" | head -3)"; continue; fi
    keys=""
    while IFS=$'\t' read -r k v; do
        [[ -n "$k" ]] || continue
        keys+="${k}"$'\n'
        VAL["${lang}|${k}"]="$v"
    done <<< "$dump"
    KEYS_OF["$lang"]="$(printf '%s' "$keys" | sort)"
    ok "${lang}.sh loads: $(printf '%s' "$keys" | grep -c .) keys"
done
(( ERRORS )) && { echo; echo "Aborting: catalogs do not load."; exit 1; }

# E0: go through the real runtime path (common.sh -> i18n_init -> t)
for lang in "${LANGS[@]}"; do
    out=$(cd "$ROOT" && BC250_LANG="$lang" bash -c 'source lib/common.sh >/dev/null 2>&1; printf "%s|%s" "$I18N_LANG" "$(t common_yn)"' 2>&1)
    if [[ "$out" == "${lang}|${VAL[${lang}|common_yn]}" ]]; then
        ok "runtime lookup works for '${lang}' (t common_yn -> ${VAL[${lang}|common_yn]})"
    else
        err "E0 runtime lookup broken for '${lang}': got '${out}', expected '${lang}|${VAL[${lang}|common_yn]}'"
    fi
done
(( ERRORS )) && { echo; echo "Aborting: runtime lookup broken."; exit 1; }

# ------------------------------------------------------------------
# E2 key parity, E4 placeholder parity, E5 stray %, W2 identical, W3 accents
# ------------------------------------------------------------------
count_ph() { # number of %s in $1 (after removing %%)
    local s="${1//%%/}"
    local n="${s//[^%]/}"
    printf '%s' "${#n}"
}

info "Cross-locale checks"
for lang in "${LANGS[@]}"; do
    [[ "$lang" == "$BASE" ]] && continue
    missing=$(comm -23 <(printf '%s\n' "${KEYS_OF[$BASE]}") <(printf '%s\n' "${KEYS_OF[$lang]}") | grep . || true)
    extra=$(comm -13 <(printf '%s\n' "${KEYS_OF[$BASE]}") <(printf '%s\n' "${KEYS_OF[$lang]}") | grep . || true)
    [[ -n "$missing" ]] && err "E2 ${lang}.sh is missing keys (falls back to English): $(echo "$missing" | tr '\n' ' ')"
    [[ -n "$extra" ]]   && err "E2 ${lang}.sh has keys absent from ${BASE}.sh: $(echo "$extra" | tr '\n' ' ')"
    [[ -z "$missing$extra" ]] && ok "${lang}.sh: same key set as ${BASE}.sh"
done

for k in $(printf '%s\n' "${KEYS_OF[$BASE]}"); do
    base_v="${VAL[${BASE}|${k}]}"
    base_n=$(count_ph "$base_v")
    for lang in "${LANGS[@]}"; do
        v="${VAL[${lang}|${k}]-}"
        [[ -n "${VAL[${lang}|${k}]+x}" ]] || continue
        # E5: any % not part of %s / %%
        stray=$(printf '%s' "$v" | sed 's/%%//g; s/%s//g' | grep -o '%' | head -1 || true)
        [[ -n "$stray" ]] && err "E5 ${lang}.sh[$k]: stray '%' (use %s or %%)"
        if [[ "$lang" != "$BASE" ]]; then
            n=$(count_ph "$v")
            (( n != base_n )) && err "E4 ${lang}.sh[$k]: $n placeholder(s) vs $base_n in ${BASE}.sh"
            if [[ "$v" == "$base_v" ]] && ! [[ "$k" =~ $SAME_OK_REGEX ]]; then
                warn "W2 ${lang}.sh[$k]: identical to ${BASE} (untranslated?)"
            fi
        fi
    done
    if printf '%s' "$base_v" | grep -qE '[éèêàùçœÉÈÊÀÙÇŒ]'; then
        warn "W3 ${BASE}.sh[$k]: contains French accented letters"
    fi
done

# ------------------------------------------------------------------
# E6 / E7 / W1: scan call sites
# ------------------------------------------------------------------
info "Scanning ${#SCRIPTS[@]} scripts for t <key> calls"
declare -A USED
multiline_note=0
# A call is "t" preceded by start-of-line or a non-identifier character
# (so -t, \t, ./t, foo_t are ignored), followed by a literal key.
CALL_RE='(^|[^A-Za-z0-9_./\\-])t[[:space:]]+[a-z][a-z0-9_]*'
# Cut $1 at the end of the call: first unbalanced ')' (end of the enclosing
# $(...)) or a top-level shell operator (; | &) outside double quotes.
cut_at_close() {
    printf '%s' "$1" | awk 'BEGIN{d=0; inq=0} {
        for(i=1;i<=length($0);i++){ c=substr($0,i,1)
            if(c=="\"" && d==0){inq=!inq; continue}
            if(inq) continue
            if(c=="(") d++
            else if(c==")"){ if(d==0){print substr($0,1,i-1); exit} d-- }
            else if(d==0 && (c==";" || c=="|" || c=="&")){print substr($0,1,i-1); exit}
        }
        print $0 }'
}
# Count shell words in $1, treating "..." and $(...) as single units.
count_words() {
    printf '%s' "$1" | awk '
        { n=0; inq=0; d=0; inword=0
          for(i=1;i<=length($0);i++){ c=substr($0,i,1)
            if(c=="\"" && d==0){inq=!inq; if(!inword){inword=1;n++}; continue}
            if(!inq){ if(c=="("){d++} else if(c==")"){d--} }
            if(c==" " && !inq && d==0){inword=0; continue}
            if(!inword){inword=1;n++}
          }
          print n }'
}
for s in "${SCRIPTS[@]}"; do
    f="${ROOT}/${s#./}"
    while IFS=: read -r ln line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue      # comment line
        for key in $(printf '%s\n' "$line" | grep -oE "$CALL_RE" | sed -E 's/^.*t[[:space:]]+//'); do
            USED["$key"]=1
            if [[ -z "${VAL[${BASE}|${key}]+x}" ]]; then
                err "E6 ${s}:${ln}: unknown key '${key}'"
                continue
            fi
            want=$(count_ph "${VAL[${BASE}|${key}]}")
            # remainder of the line after "t <key>" (key must end there)
            if [[ "$line" =~ (^|[^A-Za-z0-9_./\\-])t[[:space:]]+${key}([^a-z0-9_].*|$) ]]; then
                rest="${BASH_REMATCH[2]}"
            else
                continue
            fi
            if [[ "$rest" =~ \\$ ]]; then multiline_note=$((multiline_note+1)); continue; fi
            got=$(count_words "$(cut_at_close "$rest")")
            if (( got != want )); then
                err "E7 ${s}:${ln}: '${key}' expects ${want} arg(s), call passes ${got}: $(echo "$line" | sed 's/^[[:space:]]*//' | cut -c1-90)"
            fi
        done
    done < <(grep -nE "$CALL_RE" "$f")
done
(( multiline_note )) && info "note: ${multiline_note} multi-line call site(s) skipped for E7"

# Keys built dynamically: mod_<NN>_desc via module_desc() in install.sh
for id in $(cd "$ROOT/modules" && ls -d [0-9][0-9]-* 2>/dev/null); do
    k="mod_${id%%-*}_desc"
    USED["$k"]=1
    [[ -n "${VAL[${BASE}|${k}]+x}" ]] || err "E6 install.sh menu: no '${k}' for modules/${id}"
done

for k in $(printf '%s\n' "${KEYS_OF[$BASE]}"); do
    [[ -n "${USED[$k]+x}" ]] || warn "W1 ${BASE}.sh[$k]: defined but never used"
done


# ------------------------------------------------------------------
# E8 config examples: same variables, same values
# ------------------------------------------------------------------
info "Config examples"
base_conf="${ROOT}/config/bc250-beast.conf.example"
if [[ -f "$base_conf" ]]; then
    for f in "${ROOT}"/config/bc250-beast.conf.example.*; do
        [[ -f "$f" ]] || continue
        if diff -q <(grep -E '^[A-Za-z_]+=' "$base_conf") <(grep -E '^[A-Za-z_]+=' "$f") >/dev/null; then
            ok "$(basename "$f"): same variables/values as $(basename "$base_conf")"
        else
            err "E8 $(basename "$f") differs from $(basename "$base_conf") in variable lines:"
            diff <(grep -E '^[A-Za-z_]+=' "$base_conf") <(grep -E '^[A-Za-z_]+=' "$f") | sed 's/^/      /'
        fi
    done
else
    err "E8 ${base_conf} not found"
fi

# ------------------------------------------------------------------
# bash -n on every script, as a bonus
# ------------------------------------------------------------------
for s in "${SCRIPTS[@]}"; do
    bash -n "${ROOT}/${s#./}" 2>/dev/null || err "syntax error in ${s}"
done

echo
if (( ERRORS )); then
    printf '\033[0;31mFAILED\033[0m: %d error(s), %d warning(s)\n' "$ERRORS" "$WARNINGS"
    exit 1
fi
printf '\033[0;32mOK\033[0m: 0 errors, %d warning(s)\n' "$WARNINGS"
exit 0
