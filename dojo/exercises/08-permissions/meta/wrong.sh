#!/usr/bin/env bash
# Deliberately incorrect attempt for 08-permissions
set -euo pipefail

WORK="/home/student/dojo/08-permissions"
cd "$WORK"

chmod 777 dropbox
chmod 777 deploy.sh
chmod 777 secret-salaries.csv
mkdir -p shared-tmp
chmod 777 shared-tmp

cat > answers.txt << 'EOF'
# YetiLink ticket 08 — answer sheet. Fill values after each colon.
q1_octal_mode: 000
q2_umask_for_640: 022
EOF
