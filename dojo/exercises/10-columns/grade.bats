#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/10-columns}"
    FIXTURES_DIR="${BATS_TEST_DIRNAME:-/opt/dojo/exercises/10-columns}/meta/fixtures"
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

@test "plans.txt contains all unique plan names sorted alphabetically" {
    [ -f "${WORK}/plans.txt" ]
    [ -s "${WORK}/plans.txt" ]
    
    expected=$(tail -n +2 "${WORK}/usage.csv" | cut -d, -f3 | LC_ALL=C sort -u)
    actual=$(cat "${WORK}/plans.txt" | tr -d '\r' | sed -e 's/[[:space:]]*$//' | sed -e '/^$/d')
    
    [ "$actual" = "$expected" ]
}

@test "top5.txt contains top 5 customers by GB (tab-separated, descending)" {
    [ -f "${WORK}/top5.txt" ]
    
    line_count=$(grep -c '[^[:space:]]' "${WORK}/top5.txt" || true)
    [ "$line_count" -eq 5 ]

    # Parse student output into an array of lines
    # Verify each line matches <id><TAB><gb> format and values are descending
    prev_gb=99999999
    while IFS=$'\t' read -r cid gb; do
        [ -n "$cid" ]
        [ -n "$gb" ]
        [[ "$gb" =~ ^[0-9]+$ ]]
        [ "$gb" -le "$prev_gb" ]
        prev_gb="$gb"
    done < <(tr ',' '\t' < "${WORK}/top5.txt" | awk '{print $1 "\t" $2}')

    # Validate that the 5th GB value is at least as large as the 5th highest GB in usage.csv
    fifth_expected_gb=$(tail -n +2 "${WORK}/usage.csv" | sort -t, -k4,4nr | sed -n '5p' | cut -d, -f4)
    fifth_actual_gb=$(tr ',' '\t' < "${WORK}/top5.txt" | sed -n '5p' | awk '{print $2}')
    [ "$fifth_actual_gb" -eq "$fifth_expected_gb" ]
}

@test "q1: count of unique customers in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_unique_customers")
    [ -n "$got" ]
    
    expected=$(tail -n +2 "${WORK}/usage.csv" | cut -d, -f1 | LC_ALL=C sort -u | wc -l)
    [ "$got" -eq "$expected" ]
}

@test "q2: total data rows in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_total_rows")
    [ -n "$got" ]
    
    data_rows=$(tail -n +2 "${WORK}/usage.csv" | wc -l)
    total_lines=$(wc -l < "${WORK}/usage.csv")
    
    # Accept data rows (primary) or total lines
    [ "$got" -eq "$data_rows" ] || [ "$got" -eq "$total_lines" ]
}

@test "solution.sh is executable and correctly extracts top 5 on visible data" {
    [ -x "${WORK}/solution.sh" ]
    
    output=$(timeout 10 "${WORK}/solution.sh" "${WORK}/usage.csv")
    line_count=$(echo "$output" | grep -c '[^[:space:]]' || true)
    [ "$line_count" -eq 5 ]

    fifth_expected_gb=$(tail -n +2 "${WORK}/usage.csv" | sort -t, -k4,4nr | sed -n '5p' | cut -d, -f4)
    fifth_actual_gb=$(echo "$output" | tr ',' '\t' | sed -n '5p' | awk '{print $2}')
    [ "$fifth_actual_gb" -eq "$fifth_expected_gb" ]
}

@test "solution.sh passes hidden fixture: tie_rank5" {
    [ -x "${WORK}/solution.sh" ]
    [ -f "${FIXTURES_DIR}/tie_rank5.csv" ]
    
    output=$(timeout 10 "${WORK}/solution.sh" "${FIXTURES_DIR}/tie_rank5.csv" | tr ',' '\t')
    line_count=$(echo "$output" | grep -c '[^[:space:]]' || true)
    [ "$line_count" -eq 5 ]
    
    fifth_gb=$(echo "$output" | sed -n '5p' | awk '{print $2}')
    [ "$fifth_gb" -eq 500 ]
}

@test "solution.sh passes hidden fixture: single" {
    [ -x "${WORK}/solution.sh" ]
    [ -f "${FIXTURES_DIR}/single.csv" ]
    
    output=$(timeout 10 "${WORK}/solution.sh" "${FIXTURES_DIR}/single.csv" | tr ',' '\t' | tr -d ' \r')
    expected=$(printf "CUST-99\t350")
    [ "$output" = "$expected" ]
}

@test "solution.sh passes hidden fixture: header_only" {
    [ -x "${WORK}/solution.sh" ]
    [ -f "${FIXTURES_DIR}/header_only.csv" ]
    
    output=$(timeout 10 "${WORK}/solution.sh" "${FIXTURES_DIR}/header_only.csv" | tr -d '[:space:]')
    [ -z "$output" ]
}
