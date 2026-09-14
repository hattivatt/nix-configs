#!/usr/bin/env bash
# contacts: pick a khard contact with fuzzel, then pick one of the
# contact's fields and copy its value to the Wayland clipboard.
#
# Usage:
#   contacts [khard search terms ...]
#
# Esc in either fuzzel window aborts without copying anything.

set -euo pipefail

CONTACT_PROMPT="Contact> "
FIELD_PROMPT="Copy> "

die() { printf 'contacts: %s\n' "$*" >&2; exit 1; }

# Turn `khard show --format pretty` output into "label<TAB>value" lines.
extract_fields() {
    awk '
        BEGIN {
            typere = "^(cell|home|work|pref|main|voice|fax|pager|text|other|personal|internet|postal|parcel|dom|intl|x-[a-z0-9-]+)$"
            section = ""; key = ""; val = ""
        }
        function label_for(k) {
            if (section != "" && section != "Miscellaneous" && tolower(k) ~ typere)
                return section " (" k ")"
            return k
        }
        function emit(label, value) {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
            if (label == "" || value == "") return
            printf "%s\t%s\n", label, value
        }
        function flush() {
            if (key != "") emit(label_for(key), val)
            key = ""; val = ""
        }
        {
            if ($0 ~ /^[[:space:]]*$/) next
            if ($0 !~ /^[[:space:]]/) {
                # top level: either "Key: value" or a section header
                flush()
                if ($0 ~ /^[^:]+:[[:space:]]/) {
                    section = ""
                    k = $0; sub(/:.*/, "", k)
                    v = $0; sub(/^[^:]*:[[:space:]]*/, "", v)
                    if (k == "UID" || k == "Kind" || k == "Address book" || k == "Full name") next
                    emit(k, v)
                } else {
                    section = $0; sub(/:$/, "", section)
                }
                next
            }
            rest = $0; sub(/^[[:space:]]+/, "", rest)
            if (rest ~ /^- /) {
                # list item belonging to the current key
                item = rest; sub(/^- /, "", item)
                if (key != "") val = (val == "" ? item : val ", " item)
                next
            }
            if (rest ~ /^[^:]+:[[:space:]]*/) {
                flush()
                key = rest; sub(/:.*/, "", key)
                val = rest; sub(/^[^:]*:[[:space:]]*/, "", val)
                if (key == "UID" || key == "Version") { key = ""; val = "" }
            } else if (key != "") {
                val = (val == "" ? rest : val " " rest)
            }
        }
        END { flush() }
    '
}

main() {
    command -v khard >/dev/null 2>&1 || die "khard not found in PATH"
    command -v wl-copy >/dev/null 2>&1 || die "wl-copy not found in PATH"

    local -a rows=()
    mapfile -t rows < <(khard list --parsable "$@")
    ((${#rows[@]})) || die "no contacts found"

    local row uid name book
    local -A dup=()
    for row in "${rows[@]}"; do
        IFS=$'\t' read -r uid name book <<<"$row"
        dup[$name]=$(( ${dup[$name]:-0} + 1 ))
    done

    local -a menu=()
    for row in "${rows[@]}"; do
        IFS=$'\t' read -r uid name book <<<"$row"
        if (( ${dup[$name]} > 1 )); then
            menu+=("$name [$book]")
        else
            menu+=("$name")
        fi
    done

    local sel
    sel=$(printf '%s\n' "${menu[@]}" |
        fuzzel --dmenu --index --prompt="$CONTACT_PROMPT" --lines=15 --width=45) || exit 0
    [[ -n $sel ]] || exit 0
    IFS=$'\t' read -r uid name book <<<"${rows[$sel]}"

    local raw
    if ! raw=$(khard show --format pretty "$uid" 2>&1); then
        die "khard show failed for $name"
    fi

    local -a pairs=()
    mapfile -t pairs < <(printf '%s\n' "$raw" | extract_fields)
    ((${#pairs[@]})) || die "no copyable fields for $name"

    local -a values=() lines=()
    local pair value
    for pair in "${pairs[@]}"; do
        value=${pair#*$'\t'}
        values+=("$value")
        lines+=("${pair%%$'\t'*}: $value")
    done

    sel=$(printf '%s\n' "${lines[@]}" |
        fuzzel --dmenu --index --prompt="$FIELD_PROMPT" --lines=15 --width=65) || exit 0
    [[ -n $sel ]] || exit 0

    printf '%s' "${values[$sel]}" | wl-copy
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
