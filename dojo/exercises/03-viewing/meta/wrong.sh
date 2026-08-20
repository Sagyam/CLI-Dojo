#!/usr/bin/env bash
# Deliberately incorrect attempt for 03-viewing
set -euo pipefail

WORK="/home/student/dojo/03-viewing"
cd "$WORK"

echo "dummy line 1" > first5.txt
echo "dummy line 2" > last5.txt
echo "PANIC wrong" > panic.txt

cat > answers.txt << 'EOF'
# YetiLink ticket 03 — answer sheet. Fill values after each colon.
q1_total_lines: 100
q2_panic_line_number: 1
EOF
