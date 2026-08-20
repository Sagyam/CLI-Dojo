#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/13-log-capstone}"
    FIXTURES_DIR="${BATS_TEST_DIRNAME:-/opt/dojo/exercises/13-log-capstone}/meta/fixtures"
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

@test "top5-ips.txt contains top 5 client IPs (count<TAB>ip, descending)" {
    [ -f "${WORK}/top5-ips.txt" ]
    
    line_count=$(grep -c '[^[:space:]]' "${WORK}/top5-ips.txt" || true)
    [ "$line_count" -eq 5 ]

    # Parse and check descending count
    prev_count=99999999
    while read -r count ip; do
        [ -n "$count" ]
        [ -n "$ip" ]
        [[ "$count" =~ ^[0-9]+$ ]]
        [ "$count" -le "$prev_count" ]
        prev_count="$count"
    done < <(tr ',' '\t' < "${WORK}/top5-ips.txt" | awk '{print $1 "\t" $2}')

    # Validate top IP is the real top IP
    expected_top_ip=$(awk '{print $1}' "${WORK}/access.log" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
    actual_top_ip=$(tr ',' '\t' < "${WORK}/top5-ips.txt" | head -n 1 | awk '{print $2}')
    [ "$actual_top_ip" = "$expected_top_ip" ]
}

@test "errors-by-hour.txt contains 5xx error counts grouped by hour" {
    [ -f "${WORK}/errors-by-hour.txt" ]
    [ -s "${WORK}/errors-by-hour.txt" ]

    expected=$(awk '$9 >= 500 && $9 < 600 {
        split($4, a, ":")
        h = a[2]
        if (length(h) == 2) errs[h]++
    } END {
        for (h in errs) if (errs[h]>0) print h "\t" errs[h]
    }' "${WORK}/access.log" | LC_ALL=C sort)

    actual=$(cat "${WORK}/errors-by-hour.txt" | tr ',' '\t' | LC_ALL=C sort)
    [ "$actual" = "$expected" ]
}

@test "q1: total 5xx status code count in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_total_5xx")
    [ -n "$got" ]

    expected=$(awk '$9 >= 500 && $9 < 600 {c++} END {print c+0}' "${WORK}/access.log")
    [ "$got" -eq "$expected" ]
}

@test "q2: single busiest hour in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_busiest_hour")
    [ -n "$got" ]

    expected=$(awk '{
        split($4, a, ":")
        h = a[2]
        if (length(h) == 2) reqs[h]++
    } END {
        max=0; b=""
        for (h in reqs) if (reqs[h] > max) { max = reqs[h]; b = h }
        print b
    }' "${WORK}/access.log")

    [ "$got" = "$expected" ]
}

@test "q3: count of oversized requests (>1MB) in answers.txt is accurate" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q3_oversized_requests")
    [ -n "$got" ]

    expected=$(awk '$10 > 1048576 {c++} END {print c+0}' "${WORK}/access.log")
    [ "$got" -eq "$expected" ]
}

@test "report.sh is executable and correctly extracts top 5 IPs" {
    [ -x "${WORK}/report.sh" ]

    output=$(timeout 30 "${WORK}/report.sh" "${WORK}/access.log")
    line_count=$(echo "$output" | grep -c '[^[:space:]]' || true)
    [ "$line_count" -eq 5 ]

    expected_top_ip=$(awk '{print $1}' "${WORK}/access.log" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
    actual_top_ip=$(echo "$output" | tr ',' '\t' | head -n 1 | awk '{print $2}')
    [ "$actual_top_ip" = "$expected_top_ip" ]
}

@test "report.sh passes hidden fixture: ties" {
    [ -x "${WORK}/report.sh" ]
    [ -f "${FIXTURES_DIR}/ties.log" ]

    output=$(timeout 30 "${WORK}/report.sh" "${FIXTURES_DIR}/ties.log" | tr ',' '\t')
    line_count=$(echo "$output" | grep -c '[^[:space:]]' || true)
    [ "$line_count" -eq 5 ]
}

@test "report.sh passes hidden fixture: malformed_only" {
    [ -x "${WORK}/report.sh" ]
    [ -f "${FIXTURES_DIR}/malformed_only.log" ]

    output=$(timeout 30 "${WORK}/report.sh" "${FIXTURES_DIR}/malformed_only.log" | tr -d '[:space:]')
    [ -z "$output" ]
}

@test "report.sh passes hidden fixture: tiny" {
    [ -x "${WORK}/report.sh" ]
    [ -f "${FIXTURES_DIR}/tiny.log" ]

    output=$(timeout 30 "${WORK}/report.sh" "${FIXTURES_DIR}/tiny.log" | tr ',' '\t')
    line_count=$(echo "$output" | grep -c '[^[:space:]]' || true)
    [ "$line_count" -eq 2 ]
}
