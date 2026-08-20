#!/usr/bin/env bash
# Setup for 09-processes (The Zombie Cron of Building B)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/09-processes}"
mkdir -p "$WORK"

# 1. Cleanup any previously running instances
pkill -9 -f "^yeti-metricsd" 2>/dev/null || true
pkill -9 -f "^chaosd" 2>/dev/null || true
pkill -9 -f "^stubbornd" 2>/dev/null || true

# 2. Launch daemons with distinguishable process names as student
run_daemon() {
    local proc_name="$1"
    local trap_cmd="${2:-}"
    if command -v gosu >/dev/null 2>&1 && [[ "$(id -u)" -eq 0 ]] && id "student" >/dev/null 2>&1; then
        gosu student bash -c "exec -a \"$proc_name\" bash -c \"${trap_cmd} while true; do sleep 0.2; done\"" </dev/null >/dev/null 2>&1 &
        local pid=$!
        disown "$pid" 2>/dev/null || true
        echo "$pid"
    else
        bash -c "exec -a \"$proc_name\" bash -c \"${trap_cmd} while true; do sleep 0.2; done\"" </dev/null >/dev/null 2>&1 &
        local pid=$!
        disown "$pid" 2>/dev/null || true
        echo "$pid"
    fi
}

PID_METRICS=$(run_daemon "yeti-metricsd")
PID_CHAOS=$(run_daemon "chaosd")
PID_STUBBORN=$(run_daemon "stubbornd" "trap '' TERM;")

# Save initial PIDs into workdir helper file for grading reference
echo "$PID_CHAOS" > "${WORK}/.chaos_pid"
echo "$PID_STUBBORN" > "${WORK}/.stubborn_pid"
echo "$PID_METRICS" > "${WORK}/.metrics_pid"

cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 09 — answer sheet. Fill values after each colon.
q1_chaosd_pid: 
q2_stubbornd_pid: 
q3_metricsd_pid: 
q4_nohup_sleep_pid: 
q5_uncatchable_signal: 
EOF
