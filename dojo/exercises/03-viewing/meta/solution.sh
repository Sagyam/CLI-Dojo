#!/usr/bin/env bash
# Canonical reference solution for 03-viewing (using head/tail/grep/wc)
set -euo pipefail

WORK="/home/student/dojo/03-viewing"
cd "$WORK"

head -n 5 core-router.log > first5.txt
tail -n 5 core-router.log > last5.txt

TOTAL=$(wc -l < core-router.log | tr -d '[:space:]')
grep "PANIC" core-router.log | head -n1 > panic.txt
PANIC_LINE=$(grep -n "PANIC" core-router.log | head -n1 | cut -d: -f1)

cat > answers.txt << EOF
# YetiLink ticket 03 — answer sheet. Fill values after each colon.
q1_total_lines: ${TOTAL}
q2_panic_line_number: ${PANIC_LINE}
EOF
