#!/usr/bin/env bash
# Canonical reference solution for 09-processes
set -euo pipefail

WORK="/home/student/dojo/09-processes"
cd "$WORK"

P_CHAOS=$(pgrep -f "^chaosd" | head -n1)
P_STUBBORN=$(pgrep -f "^stubbornd" | head -n1)
P_METRICS=$(pgrep -f "^yeti-metricsd" | head -n1)

kill -15 "$P_CHAOS" 2>/dev/null || true
kill -15 "$P_STUBBORN" 2>/dev/null || true
kill -9 "$P_STUBBORN" 2>/dev/null || true

nohup sleep 600 >/dev/null 2>&1 &
P_SLEEP=$!

cat > answers.txt << EOF
# YetiLink ticket 09 — answer sheet. Fill values after each colon.
q1_chaosd_pid: ${P_CHAOS}
q2_stubbornd_pid: ${P_STUBBORN}
q3_metricsd_pid: ${P_METRICS}
q4_nohup_sleep_pid: ${P_SLEEP}
q5_uncatchable_signal: 9
EOF
