#!/usr/bin/env bash
# Alternative solution for 03-viewing (using sed and awk)
set -euo pipefail

WORK="/home/student/dojo/03-viewing"
cd "$WORK"

sed -n '1,5p' core-router.log > first5.txt
awk -v n=5 '{for(i=1;i<n;i++)line[i]=line[i+1];line[n]=$0}END{for(i=1;i<=n;i++)print line[i]}' core-router.log > last5.txt

TOTAL=$(awk 'END{print NR}' core-router.log)
sed -n '/PANIC/p' core-router.log | head -n1 > panic.txt
PANIC_LINE=$(sed -n '/PANIC/=' core-router.log | head -n1)

sed -i "s/^q1_total_lines:.*/q1_total_lines: ${TOTAL}/" answers.txt
sed -i "s/^q2_panic_line_number:.*/q2_panic_line_number: ${PANIC_LINE}/" answers.txt
