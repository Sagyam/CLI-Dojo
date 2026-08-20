#!/usr/bin/env bash
# Setup for 00-orientation
set -euo pipefail

WORK="${WORK:-/home/student/dojo/00-orientation}"
mkdir -p "$WORK"

cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 00 — answer sheet. Fill values after each colon.
q1_hostname: 
EOF
