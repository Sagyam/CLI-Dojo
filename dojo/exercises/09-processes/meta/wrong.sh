#!/usr/bin/env bash
# Deliberately incorrect attempt for 09-processes (kills legit metrics daemon and leaves stubbornd alive)
set -euo pipefail

WORK="/home/student/dojo/09-processes"
cd "$WORK"

pkill -9 -f "^yeti-metricsd" 2>/dev/null || true
# Fails to kill stubbornd because only TERM is sent
pkill -15 -f "^stubbornd" 2>/dev/null || true

cat > answers.txt << 'EOF'
# YetiLink ticket 09 — answer sheet. Fill values after each colon.
q1_chaosd_pid: 1
q2_stubbornd_pid: 1
q3_metricsd_pid: 1
q4_nohup_sleep_pid: 0
q5_uncatchable_signal: 15
EOF
