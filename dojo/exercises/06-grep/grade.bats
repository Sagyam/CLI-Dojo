#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/06-grep}"
    FIXTURES_DIR="${BATS_TEST_DIRNAME:-/opt/dojo/exercises/06-grep}/meta/fixtures"
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

@test "q1: path of rogue nameserver config in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_rogue_file_path")
    [ -n "$got" ]
    
    # Calculate real rogue file
    expected=$(grep -rn "nameserver" "${WORK}/configs" | grep -v "10.10.0.53" | cut -d: -f1 | head -n1)
    
    if [[ "$got" != /* ]]; then
        got_real=$(realpath "${WORK}/${got}" 2>/dev/null || echo "$got")
    else
        got_real="$got"
    fi
    expected_real=$(realpath "$expected")
    [ "$got_real" = "$expected_real" ]
}

@test "q2: rogue IP address in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_rogue_ip")
    [ -n "$got" ]
    
    expected=$(grep -rh "nameserver" "${WORK}/configs" | grep -v "10.10.0.53" | awk '{print $2}' | head -n1)
    [ "$got" = "$expected" ]
}

@test "q3: total failed login count in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q3_failed_login_lines")
    [ -n "$got" ]
    
    expected=$(grep -c "Failed password" "${WORK}/auth.log")
    [ "$got" -eq "$expected" ]
}

@test "q4: count of unique failing IPs in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q4_unique_failing_ips")
    [ -n "$got" ]
    
    expected=$(grep "Failed password" "${WORK}/auth.log" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | LC_ALL=C sort -u | wc -l)
    [ "$got" -eq "$expected" ]
}

@test "context.txt contains rogue line with 2 lines of surrounding context" {
    [ -f "${WORK}/context.txt" ]
    
    rogue_file=$(grep -rn "nameserver" "${WORK}/configs" | grep -v "10.10.0.53" | cut -d: -f1 | head -n1)
    expected_context=$(grep -C 2 "nameserver" "$rogue_file" | tr -d '\r')
    actual_context=$(cat "${WORK}/context.txt" | tr -d '\r' | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba')
    
    # Check that rogue IP is inside context and length is around 5 lines
    grep -q "nameserver 198.51.100." "${WORK}/context.txt"
    line_count=$(wc -l < "${WORK}/context.txt")
    [ "$line_count" -ge 4 ]
}

@test "solution.sh is executable and correctly filters visible configs" {
    [ -x "${WORK}/solution.sh" ]
    
    expected_rogue=$(realpath $(grep -rn "nameserver" "${WORK}/configs" | grep -v "10.10.0.53" | cut -d: -f1 | head -n1))
    
    output=$(timeout 10 "${WORK}/solution.sh" "${WORK}/configs" | while read -r l; do realpath "$l" 2>/dev/null || echo "$l"; done | LC_ALL=C sort -u)
    [ "$output" = "$expected_rogue" ]
}

@test "solution.sh passes hidden fixture: dir_first" {
    [ -x "${WORK}/solution.sh" ]
    [ -d "${FIXTURES_DIR}/dir_first" ]
    
    output=$(timeout 10 "${WORK}/solution.sh" "${FIXTURES_DIR}/dir_first" | while read -r l; do basename "$l"; done | LC_ALL=C sort -u)
    [ "$output" = "node_001.conf" ]
}

@test "solution.sh passes hidden fixture: dir_none" {
    [ -x "${WORK}/solution.sh" ]
    [ -d "${FIXTURES_DIR}/dir_none" ]
    
    output=$(timeout 10 "${WORK}/solution.sh" "${FIXTURES_DIR}/dir_none" | tr -d '[:space:]')
    [ -z "$output" ]
}

@test "solution.sh passes hidden fixture: dir_multi" {
    [ -x "${WORK}/solution.sh" ]
    [ -d "${FIXTURES_DIR}/dir_multi" ]
    
    output=$(timeout 10 "${WORK}/solution.sh" "${FIXTURES_DIR}/dir_multi" | while read -r l; do basename "$l"; done | LC_ALL=C sort -u)
    expected=$(printf "a.conf\nb.conf\n" | LC_ALL=C sort -u)
    [ "$output" = "$expected" ]
}
