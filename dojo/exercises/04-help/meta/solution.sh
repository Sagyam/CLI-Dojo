#!/usr/bin/env bash
# Canonical reference solution for 04-help
set -euo pipefail

WORK="/home/student/dojo/04-help"
cd "$WORK"

cat > answers.txt << 'EOF'
# YetiLink ticket 04 — answer sheet. Fill values after each colon.
q1_crontab_format_section: 5
q2_cd_type: builtin
q3_awk_binary_path: /usr/bin/awk
q4_typescript_cmd: script
q5_sysadmin_man_section: 8
EOF
