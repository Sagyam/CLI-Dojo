#!/usr/bin/env bash
# Alternative solution for 04-help (using shell builtin / gawk variations)
set -euo pipefail

WORK="/home/student/dojo/04-help"
cd "$WORK"

AWK_PATH=$(command -v awk)

cat > answers.txt << EOF
# YetiLink ticket 04 — answer sheet. Fill values after each colon.
q1_crontab_format_section: 5
q2_cd_type: shell builtin
q3_awk_binary_path: ${AWK_PATH}
q4_typescript_cmd: script
q5_sysadmin_man_section: 8
EOF
