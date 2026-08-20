#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/09-processes}"
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

@test "chaosd is no longer running" {
    ! pgrep -f "^chaosd" >/dev/null 2>&1
}

@test "stubbornd is no longer running" {
    ! pgrep -f "^stubbornd" >/dev/null 2>&1
}

@test "yeti-metricsd is still running" {
    pgrep -f "^yeti-metricsd" >/dev/null 2>&1
}

@test "q1: chaosd initial PID in answers.txt matches" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_chaosd_pid")
    [ -n "$got" ]
    
    if [[ -f "${WORK}/.chaos_pid" ]]; then
        expected=$(cat "${WORK}/.chaos_pid")
        [ "$got" -eq "$expected" ]
    fi
}

@test "q2: stubbornd initial PID in answers.txt matches" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_stubbornd_pid")
    [ -n "$got" ]
    
    if [[ -f "${WORK}/.stubborn_pid" ]]; then
        expected=$(cat "${WORK}/.stubborn_pid")
        [ "$got" -eq "$expected" ]
    fi
}

@test "q3: yeti-metricsd initial PID in answers.txt matches" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q3_metricsd_pid")
    [ -n "$got" ]
    
    if [[ -f "${WORK}/.metrics_pid" ]]; then
        expected=$(cat "${WORK}/.metrics_pid")
        [ "$got" -eq "$expected" ]
    fi
}

@test "q4: nohup background sleep PID was recorded" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q4_nohup_sleep_pid")
    [ -n "$got" ]
    [ "$got" -gt 1 ]
}

@test "q5: uncatchable signal number identified as 9 or SIGKILL" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q5_uncatchable_signal" | tr '[:lower:]' '[:upper:]')
    [[ "$got" == "9" || "$got" == *"SIGKILL"* || "$got" == *"KILL"* ]]
}
