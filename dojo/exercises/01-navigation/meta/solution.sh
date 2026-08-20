#!/usr/bin/env bash
# Canonical reference solution for 01-navigation
set -euo pipefail

WORK="/home/student/dojo/01-navigation"

TREASURE_PATH=$(find "${WORK}/fake-root" -name "treasure.txt" | head -n1)
LARGEST_BYTES=$(find "${WORK}/fake-root/var" -type f -exec stat -c %s {} + | sort -n | tail -n1)
DISGUISED_TYPE=$(file -b "${WORK}/fake-root/etc/network/vpn-adapter.conf" | cut -d',' -f1)
HIDDEN_COUNT=$(find "${WORK}/fake-root/opt/backup" -maxdepth 1 -name ".*" ! -name "." ! -name ".." | wc -l)
RELATIVE_CHOICE="b"

cat > "${WORK}/answers.txt" << EOF
# YetiLink ticket 01 — answer sheet. Fill values after each colon.
q1_treasure_path: ${TREASURE_PATH}
q2_largest_var_bytes: ${LARGEST_BYTES}
q3_disguised_file_type: ${DISGUISED_TYPE}
q4_hidden_file_count: ${HIDDEN_COUNT}
q5_relative_path_choice: ${RELATIVE_CHOICE}
EOF
