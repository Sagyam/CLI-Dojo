#!/usr/bin/env bash
# Alternative solution for 01-navigation (using ls, du, sed, awk)
set -euo pipefail

WORK="/home/student/dojo/01-navigation"

TREASURE_PATH=$(realpath "${WORK}/fake-root/opt/app/v1/"*/*/"treasure.txt" 2>/dev/null || find "${WORK}/fake-root" -name "treasure.txt")
LARGEST_BYTES=$(find "${WORK}/fake-root/var" -type f -exec du -b {} + | sort -n | tail -n1 | awk '{print $1}')
DISGUISED_TYPE="PNG image data"
HIDDEN_COUNT=$(find "${WORK}/fake-root/opt/backup" -mindepth 1 -maxdepth 1 -name ".*" | wc -l)
RELATIVE_CHOICE="b"

sed -i "s|^q1_treasure_path:.*|q1_treasure_path: ${TREASURE_PATH}|" "${WORK}/answers.txt"
sed -i "s|^q2_largest_var_bytes:.*|q2_largest_var_bytes: ${LARGEST_BYTES}|" "${WORK}/answers.txt"
sed -i "s|^q3_disguised_file_type:.*|q3_disguised_file_type: ${DISGUISED_TYPE}|" "${WORK}/answers.txt"
sed -i "s|^q4_hidden_file_count:.*|q4_hidden_file_count: ${HIDDEN_COUNT}|" "${WORK}/answers.txt"
sed -i "s|^q5_relative_path_choice:.*|q5_relative_path_choice: ${RELATIVE_CHOICE}|" "${WORK}/answers.txt"
