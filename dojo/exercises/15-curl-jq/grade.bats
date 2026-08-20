#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/15-curl-jq}"
    PORT=$(cat "${WORK}/API_PORT" 2>/dev/null || echo "8888")
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

@test "API server is running and responsive on API_PORT" {
    [ -f "${WORK}/API_PORT" ]
    res=$(curl -s "http://127.0.0.1:${PORT}/health" || true)
    echo "$res" | grep -q '"status": "ok"'
}

@test "health.json exists and contains valid JSON health payload" {
    [ -f "${WORK}/health.json" ]
    [ -s "${WORK}/health.json" ]
    jq -e '.status == "ok"' "${WORK}/health.json" >/dev/null
    jq -e '.service == "yetilink-billing-api"' "${WORK}/health.json" >/dev/null
}

@test "q1: unauthenticated POST status code in answers.txt is 401" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_post_status_unauth")
    [ -n "$got" ]
    [ "$got" -eq 401 ]
}

@test "q2: authenticated POST status code in answers.txt is 201" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_post_status_auth")
    [ -n "$got" ]
    [ "$got" -eq 201 ]
}

@test "names.txt exists and contains raw customer names (no JSON quotes)" {
    [ -f "${WORK}/names.txt" ]
    [ -s "${WORK}/names.txt" ]
    
    # Check no double quotes present
    ! grep -q '"' "${WORK}/names.txt"
    
    # Verify against live API
    expected_names=$(curl -s "http://127.0.0.1:${PORT}/customers" | jq -r '.[].name')
    actual_names=$(cat "${WORK}/names.txt")
    
    [ "$actual_names" = "$expected_names" ]
}

@test "premium.txt exists and contains only premium customer IDs" {
    [ -f "${WORK}/premium.txt" ]
    [ -s "${WORK}/premium.txt" ]
    
    # Check no double quotes present
    ! grep -q '"' "${WORK}/premium.txt"
    
    expected_premium=$(curl -s "http://127.0.0.1:${PORT}/customers" | jq -r '.[] | select(.plan == "premium") | .id')
    actual_premium=$(cat "${WORK}/premium.txt")
    
    [ "$actual_premium" = "$expected_premium" ]
}

@test "q3: customer count in answers.txt matches API length" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q3_customer_count")
    [ -n "$got" ]
    
    expected_count=$(curl -s "http://127.0.0.1:${PORT}/customers" | jq 'length')
    [ "$got" -eq "$expected_count" ]
}
