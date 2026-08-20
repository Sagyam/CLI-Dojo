#!/usr/bin/env bash
# Deliberately incorrect attempt for 01-navigation
set -euo pipefail

WORK="/home/student/dojo/01-navigation"

cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 01 — answer sheet. Fill values after each colon.
q1_treasure_path: /tmp/fake_treasure.txt
q2_largest_var_bytes: 999999
q3_disguised_file_type: ASCII text
q4_hidden_file_count: 0
q5_relative_path_choice: a
EOF
