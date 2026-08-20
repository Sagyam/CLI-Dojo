#!/usr/bin/env bash
# YetiLink CLI Dojo — Exercise CI Meta-Test Harness (run-exercise-ci.sh)
# Usage: ci/run-exercise-ci.sh <NN> <SEED>
set -euo pipefail

# ANSI color codes
readonly C_RESET='\033[0m'
readonly C_BOLD='\033[1m'
readonly C_RED='\033[31m'
readonly C_GREEN='\033[32m'
readonly C_CYAN='\033[36m'

log_step() {
    echo -e "${C_BOLD}${C_CYAN}==> [CI ${EX_ID}] ${1}${C_RESET}"
}

log_pass() {
    echo -e "${C_BOLD}${C_GREEN}  ✓ ${1}${C_RESET}"
}

log_fail() {
    echo -e "${C_BOLD}${C_RED}  ✗ ${1}${C_RESET}"
}

die() {
    echo -e "${C_BOLD}${C_RED}FATAL: ${1}${C_RESET}" >&2
    exit 1
}

if [[ $# -lt 2 ]]; then
    die "Usage: run-exercise-ci.sh <NN> <SEED>"
fi

RAW_ID="$1"
SEED="$2"

if [[ ! "$RAW_ID" =~ ^[0-9]{1,2}$ ]]; then
    die "Invalid exercise ID: '$RAW_ID'"
fi

EX_ID=$(printf "%02d" "$((10#$RAW_ID))")

# Resolve exercise directory
EX_DIR=""
for d in /opt/dojo/exercises/"${EX_ID}"-*; do
    if [[ -d "$d" ]]; then
        EX_DIR="$d"
        break
    fi
done

if [[ -z "$EX_DIR" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
    for d in "${REPO_ROOT}"/dojo/exercises/"${EX_ID}"-*; do
        if [[ -d "$d" ]]; then
            EX_DIR="$d"
            break
        fi
    done
fi

[[ -n "$EX_DIR" ]] || die "Cannot resolve exercise directory for ${EX_ID}"
EX_SLUG="$(basename "$EX_DIR")"

echo -e "${C_BOLD}${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo -e "${C_BOLD}Running Meta-Test Contract on Ticket ${EX_ID} (${EX_SLUG}) [Seed: ${SEED}]${C_RESET}"
echo -e "${C_BOLD}${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"

run_script_as_student() {
    local script_file="$1"
    if command -v gosu >/dev/null 2>&1 && [[ "$(id -u)" -eq 0 ]]; then
        gosu student bash < "$script_file"
    elif [[ "$(id -u)" -eq 0 ]]; then
        su -s /bin/bash student < "$script_file"
    else
        bash < "$script_file"
    fi
}

# 1. Step 1 & 2: Setup and verify fresh state FAILS
log_step "Step 1 & 2: Setup fresh exercise and verify it FAILS grading..."
/opt/dojo/bin/dojo-setup "$EX_ID" "$SEED" >/dev/null

set +e
/opt/dojo/bin/dojo-grade "$EX_ID" >/dev/null 2>&1
GRADE_EXIT=$?
set -e

if [[ $GRADE_EXIT -eq 0 ]]; then
    log_fail "Fresh setup passed grading! Vacuous grader detected."
    exit 1
fi
log_pass "Fresh setup correctly failed grading."

# 2. Step 3 & 4: Run canonical solution and verify it PASSES
log_step "Step 3 & 4: Run canonical solution and verify it PASSES..."
SOL_SCRIPT="${EX_DIR}/meta/solution.sh"
if [[ ! -f "$SOL_SCRIPT" ]]; then
    die "Canonical solution script not found: ${SOL_SCRIPT}"
fi

run_script_as_student "$SOL_SCRIPT"

set +e
/opt/dojo/bin/dojo-grade "$EX_ID" >/dev/null 2>&1
GRADE_EXIT=$?
set -e

if [[ $GRADE_EXIT -ne 0 ]]; then
    log_fail "Canonical solution FAILED grading!"
    echo "--- Grader output below ---"
    /opt/dojo/bin/dojo-grade "$EX_ID" || true
    exit 1
fi
log_pass "Canonical solution passed grading."

# 3. Step 5: For each alt solution in meta/alt/, re-setup, run alt, verify it PASSES
if [[ -d "${EX_DIR}/meta/alt" ]]; then
    for alt in "${EX_DIR}/meta/alt/"*.sh; do
        [[ -f "$alt" ]] || continue
        ALT_NAME="$(basename "$alt")"
        log_step "Step 5: Testing alternative solution (${ALT_NAME})..."
        
        /opt/dojo/bin/dojo-setup "$EX_ID" "$SEED" >/dev/null
        run_script_as_student "$alt"
        
        set +e
        /opt/dojo/bin/dojo-grade "$EX_ID" >/dev/null 2>&1
        GRADE_EXIT=$?
        set -e
        
        if [[ $GRADE_EXIT -ne 0 ]]; then
            log_fail "Alt solution '${ALT_NAME}' FAILED grading!"
            echo "--- Grader output below ---"
            /opt/dojo/bin/dojo-grade "$EX_ID" || true
            exit 1
        fi
        log_pass "Alt solution '${ALT_NAME}' passed grading."
    done
fi

# 4. Step 6: If meta/wrong.sh exists, re-setup, run wrong, verify it FAILS
WRONG_SCRIPT="${EX_DIR}/meta/wrong.sh"
if [[ -f "$WRONG_SCRIPT" ]]; then
    log_step "Step 6: Testing deliberately incorrect attempt (meta/wrong.sh)..."
    /opt/dojo/bin/dojo-setup "$EX_ID" "$SEED" >/dev/null
    run_script_as_student "$WRONG_SCRIPT"
    
    set +e
    /opt/dojo/bin/dojo-grade "$EX_ID" >/dev/null 2>&1
    GRADE_EXIT=$?
    set -e
    
    if [[ $GRADE_EXIT -eq 0 ]]; then
        log_fail "Wrong solution PASSED grading! Over-lenient grader detected."
        exit 1
    fi
    log_pass "Wrong solution correctly failed grading."
fi

echo -e "${C_BOLD}${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo -e "${C_BOLD}${C_GREEN} ✓ Ticket ${EX_ID} contract verified on seed ${SEED}${C_RESET}"
echo -e "${C_BOLD}${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo ""
