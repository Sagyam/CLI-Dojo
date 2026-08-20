#!/usr/bin/env bash
# Deliberately incorrect attempt for 04-help
set -euo pipefail

WORK="/home/student/dojo/04-help"
cd "$WORK"

cat > answers.txt << 'EOF'
# YetiLink ticket 04 — answer sheet. Fill values after each colon.
q1_crontab_format_section: 1
q2_cd_type: binary
q3_awk_binary_path: /bin/false
q4_typescript_cmd: tmux
q5_sysadmin_man_section: 2
EOF
