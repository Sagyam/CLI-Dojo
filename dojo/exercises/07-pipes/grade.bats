#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/07-pipes}"
    FIXTURES_DIR="${BATS_TEST_DIRNAME:-/opt/dojo/exercises/07-pipes}/meta/fixtures"
    
    SEED_FILE="/opt/dojo/state/07.seed"
    if [[ -f "$SEED_FILE" ]]; then
        SEED=$(cat "$SEED_FILE")
    else
        SEED=42
    fi
    seed_init "$SEED"
}

get_answer() {
    local key="$1"
    awk -F ':' -v k="$key" '
        $1 ~ "^[[:space:]]*" k "[[:space:]]*$" {
            val = substr($0, index($0, ":") + 1)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
            print val
        }
    ' "${WORK}/answers.txt"
}

@test "out.log contains only stdout lines" {
    [ -f "${WORK}/out.log" ]
    grep -q "STDOUT_" "${WORK}/out.log"
    ! grep -q "STDERR_" "${WORK}/out.log"
}

@test "err.log contains only stderr lines" {
    [ -f "${WORK}/err.log" ]
    grep -q "STDERR_" "${WORK}/err.log"
    ! grep -q "STDOUT_" "${WORK}/err.log"
}

@test "combined.log contains both stdout and stderr lines" {
    [ -f "${WORK}/combined.log" ]
    grep -q "STDOUT_" "${WORK}/combined.log"
    grep -q "STDERR_" "${WORK}/combined.log"
}

@test "seen.log and archive.log contain identical stdout output via tee" {
    [ -f "${WORK}/seen.log" ]
    [ -f "${WORK}/archive.log" ]
    grep -q "STDOUT_" "${WORK}/seen.log"
    ! grep -q "STDERR_" "${WORK}/seen.log"
    diff -q "${WORK}/seen.log" "${WORK}/archive.log"
}

@test "wrong.log demonstrates missing stderr from incorrect 2>&1 > wrong.log order" {
    [ -f "${WORK}/wrong.log" ]
    grep -q "STDOUT_" "${WORK}/wrong.log"
    ! grep -q "STDERR_" "${WORK}/wrong.log"
}

@test "right.log contains both stdout and stderr from correct > right.log 2>&1 order" {
    [ -f "${WORK}/right.log" ]
    grep -q "STDOUT_" "${WORK}/right.log"
    grep -q "STDERR_" "${WORK}/right.log"
}

@test "q1: script exit code in answers.txt matches expected" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_script_exit_code")
    [ -n "$got" ]
    
    # In setup: TAG_OUT(seeded_hex 6 -> 6 hex chars consumes 6 next), TAG_ERR(6 next), EXIT_CODE is seeded_int 7 42
    # But we can execute noisy-backup.sh directly to see its actual exit code!
    set +e
    "${WORK}/noisy-backup.sh" >/dev/null 2>&1
    expected=$?
    set -e
    
    [ "$got" -eq "$expected" ]
}

@test "redirect.sh executes command separating stdout to clean.out and stderr to clean.err" {
    [ -x "${WORK}/redirect.sh" ]
    
    cd "${WORK}"
    rm -f clean.out clean.err
    "${WORK}/redirect.sh" "${FIXTURES_DIR}/hidden-noisy.sh" || true
    
    [ -f "${WORK}/clean.out" ]
    [ -f "${WORK}/clean.err" ]
    
    grep -q "HIDDEN_STDOUT" "${WORK}/clean.out"
    ! grep -q "HIDDEN_STDERR" "${WORK}/clean.out"
    
    grep -q "HIDDEN_STDERR" "${WORK}/clean.err"
    ! grep -q "HIDDEN_STDOUT" "${WORK}/clean.err"
}
