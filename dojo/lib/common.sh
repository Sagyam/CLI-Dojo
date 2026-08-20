#!/usr/bin/env bash
# YetiLink CLI Dojo — Common Library (common.sh)
set -euo pipefail

# ANSI color codes
readonly C_RESET='\033[0m'
readonly C_BOLD='\033[1m'
readonly C_RED='\033[31m'
readonly C_GREEN='\033[32m'
readonly C_YELLOW='\033[33m'
readonly C_BLUE='\033[34m'
readonly C_MAGENTA='\033[35m'
readonly C_CYAN='\033[36m'
readonly C_WHITE='\033[37m'
readonly C_MUTED='\033[90m'

log_info() {
    printf "${C_BLUE}ℹ %b${C_RESET}\n" "$*" >&2
}

log_success() {
    printf "${C_GREEN}✓ %b${C_RESET}\n" "$*" >&2
}

log_warn() {
    printf "${C_YELLOW}⚠ %b${C_RESET}\n" "$*" >&2
}

log_error() {
    printf "${C_RED}✗ %b${C_RESET}\n" "$*" >&2
}

die() {
    log_error "$*"
    exit 1
}

# Normalize exercise ID (e.g. 5 -> 05, 05 -> 05)
normalize_ex_id() {
    local raw="${1:-}"
    if [[ ! "$raw" =~ ^[0-9]{1,2}$ ]]; then
        return 1
    fi
    printf "%02d" "$((10#$raw))"
}

# Find exercise directory in /opt/dojo/exercises/
get_exercise_dir() {
    local ex_id
    ex_id=$(normalize_ex_id "${1:-}") || die "Invalid exercise ID: ${1:-}. Expected 00-20."
    
    local ex_base="/opt/dojo/exercises"
    local matches=()
    while IFS= read -r -d $'\0' d; do
        matches+=("$d")
    done < <(find "$ex_base" -mindepth 1 -maxdepth 1 -type d -name "${ex_id}-*" -print0)

    if [[ ${#matches[@]} -eq 0 ]]; then
        die "Exercise ${ex_id} not found under ${ex_base}."
    elif [[ ${#matches[@]} -gt 1 ]]; then
        die "Multiple exercise directories matched ${ex_id} under ${ex_base}."
    fi

    printf "%s" "${matches[0]}"
}

get_exercise_slug() {
    local ex_dir
    ex_dir=$(get_exercise_dir "${1:-}")
    basename "$ex_dir"
}

# Progress file path
PROGRESS_FILE="${DOJO_PROGRESS_FILE:-/home/student/.dojo/progress.json}"

init_progress_file() {
    local dir
    dir="$(dirname "$PROGRESS_FILE")"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        chmod 777 "$dir" 2>/dev/null || true
        if id student >/dev/null 2>&1; then
            chown student:student "$dir" 2>/dev/null || true
        fi
    fi
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        echo '{"exercises":{}}' > "$PROGRESS_FILE"
        chmod 666 "$PROGRESS_FILE" 2>/dev/null || true
        if id student >/dev/null 2>&1; then
            chown student:student "$PROGRESS_FILE" 2>/dev/null || true
        fi
    else
        chmod 666 "$PROGRESS_FILE" 2>/dev/null || true
    fi
}

get_progress_val() {
    local ex_id="$1"
    local field="$2"
    local default_val="${3:-null}"

    init_progress_file
    jq -r ".exercises[\"${ex_id}\"].${field} // ${default_val}" "$PROGRESS_FILE" 2>/dev/null || echo "$default_val"
}

update_progress() {
    local ex_id="$1"
    local jq_expr="$2"

    init_progress_file
    local tmp
    tmp=$(mktemp "/tmp/dojo_progress.XXXXXX")
    jq ".exercises[\"${ex_id}\"] |= (. // {}) | .exercises[\"${ex_id}\"] |= (${jq_expr})" "$PROGRESS_FILE" > "$tmp"
    cat "$tmp" > "$PROGRESS_FILE"
    rm -f "$tmp"
    chmod 666 "$PROGRESS_FILE" 2>/dev/null || true
}
