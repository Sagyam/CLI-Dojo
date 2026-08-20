#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/03-viewing}"
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

@test "first5.txt exists and contains the exact first 5 lines" {
    [ -f "${WORK}/first5.txt" ]
    expected=$(head -n 5 "${WORK}/core-router.log" | tr -d '\r')
    actual=$(cat "${WORK}/first5.txt" | tr -d '\r' | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba')
    [ "$actual" = "$expected" ]
}

@test "last5.txt exists and contains the exact last 5 lines" {
    [ -f "${WORK}/last5.txt" ]
    expected=$(tail -n 5 "${WORK}/core-router.log" | tr -d '\r')
    actual=$(cat "${WORK}/last5.txt" | tr -d '\r' | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba')
    [ "$actual" = "$expected" ]
}

@test "q1: total line count in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_total_lines")
    [ -n "$got" ]
    
    expected=$(wc -l < "${WORK}/core-router.log" | tr -d '[:space:]')
    [ "$got" -eq "$expected" ]
}

@test "panic.txt contains the exact PANIC log line" {
    [ -f "${WORK}/panic.txt" ]
    expected=$(grep "PANIC" "${WORK}/core-router.log" | head -n1 | tr -d '[:space:]')
    actual=$(cat "${WORK}/panic.txt" | tr -d '[:space:]')
    [ "$actual" = "$expected" ]
}

@test "q2: panic line number in answers.txt is exact" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_panic_line_number")
    [ -n "$got" ]
    
    expected=$(grep -n "PANIC" "${WORK}/core-router.log" | cut -d: -f1)
    [ "$got" -eq "$expected" ]
}
