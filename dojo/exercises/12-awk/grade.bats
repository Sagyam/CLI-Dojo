#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/12-awk}"
    FIXTURES_DIR="${BATS_TEST_DIRNAME:-/opt/dojo/exercises/12-awk}/meta/fixtures"
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

@test "q1: overall average latency in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_avg_latency")
    [ -n "$got" ]

    # Tolerant numeric policy: accept either floor or rounded integer division
    expected_floor=$(awk '{sum += $3} END {if (NR>0) print int(sum/NR)}' "${WORK}/pings.log")
    expected_round=$(awk '{sum += $3} END {if (NR>0) print int(sum/NR + 0.5)}' "${WORK}/pings.log")

    [ "$got" -eq "$expected_floor" ] || [ "$got" -eq "$expected_round" ]
}

@test "q2: count of pings >100ms in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_high_latency_count")
    [ -n "$got" ]

    expected=$(awk '$3 > 100 {count++} END {print count+0}' "${WORK}/pings.log")
    [ "$got" -eq "$expected" ]
}

@test "revenue.txt contains aggregated GB per plan (tab-separated, sorted)" {
    [ -f "${WORK}/revenue.txt" ]
    [ -s "${WORK}/revenue.txt" ]

    expected=$(awk -F, 'NR>1 {plan[$3] += $4} END {for (p in plan) print p "\t" plan[p]}' "${WORK}/usage.csv" | LC_ALL=C sort)
    actual=$(cat "${WORK}/revenue.txt" | tr ',' '\t' | LC_ALL=C sort)

    [ "$actual" = "$expected" ]
}

@test "slow.txt contains deduped, sorted list of hosts with latency >100ms" {
    [ -f "${WORK}/slow.txt" ]
    [ -s "${WORK}/slow.txt" ]

    expected=$(awk '$3 > 100 {print $2}' "${WORK}/pings.log" | LC_ALL=C sort -u)
    actual=$(cat "${WORK}/slow.txt" | sed -e 's/[[:space:]]*$//' | sed -e '/^$/d' | LC_ALL=C sort -u)

    [ "$actual" = "$expected" ]
}

@test "solution.sh is executable and calculates average latency on visible data" {
    [ -x "${WORK}/solution.sh" ]

    output=$(timeout 10 "${WORK}/solution.sh" "${WORK}/pings.log" | tr -d '[:space:]')
    [ -n "$output" ]

    expected_floor=$(awk '{sum += $3} END {if (NR>0) print int(sum/NR)}' "${WORK}/pings.log")
    expected_round=$(awk '{sum += $3} END {if (NR>0) print int(sum/NR + 0.5)}' "${WORK}/pings.log")

    [ "$output" -eq "$expected_floor" ] || [ "$output" -eq "$expected_round" ]
}

@test "solution.sh passes hidden fixture: div_round" {
    [ -x "${WORK}/solution.sh" ]
    [ -f "${FIXTURES_DIR}/div_round.log" ]

    output=$(timeout 10 "${WORK}/solution.sh" "${FIXTURES_DIR}/div_round.log" | tr -d '[:space:]')
    [ -n "$output" ]

    expected_floor=$(awk '{sum += $3} END {if (NR>0) print int(sum/NR)}' "${FIXTURES_DIR}/div_round.log")
    expected_round=$(awk '{sum += $3} END {if (NR>0) print int(sum/NR + 0.5)}' "${FIXTURES_DIR}/div_round.log")

    [ "$output" -eq "$expected_floor" ] || [ "$output" -eq "$expected_round" ]
}

@test "solution.sh passes hidden fixture: single_row" {
    [ -x "${WORK}/solution.sh" ]
    [ -f "${FIXTURES_DIR}/single_row.log" ]

    output=$(timeout 10 "${WORK}/solution.sh" "${FIXTURES_DIR}/single_row.log" | tr -d '[:space:]')
    [ "$output" -eq 42 ]
}

@test "solution.sh passes hidden fixture: boundary_100" {
    [ -x "${WORK}/solution.sh" ]
    [ -f "${FIXTURES_DIR}/boundary_100.log" ]

    output=$(timeout 10 "${WORK}/solution.sh" "${FIXTURES_DIR}/boundary_100.log" | tr -d '[:space:]')
    [ -n "$output" ]

    expected_floor=$(awk '{sum += $3} END {if (NR>0) print int(sum/NR)}' "${FIXTURES_DIR}/boundary_100.log")
    expected_round=$(awk '{sum += $3} END {if (NR>0) print int(sum/NR + 0.5)}' "${FIXTURES_DIR}/boundary_100.log")

    [ "$output" -eq "$expected_floor" ] || [ "$output" -eq "$expected_round" ]
}
