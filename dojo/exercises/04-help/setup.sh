#!/usr/bin/env bash
# Setup for 04-help (RTFM, Respectfully)
set -euo pipefail

WORK="${WORK:-/home/student/dojo/04-help}"
mkdir -p "$WORK"

cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 04 — answer sheet. Fill values after each colon.
q1_crontab_format_section: 
q2_cd_type: 
q3_awk_binary_path: 
q4_typescript_cmd: 
q5_sysadmin_man_section: 
EOF
