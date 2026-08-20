#!/usr/bin/env bash
# Canonical reference solution for 02-file-ops (using mv)
set -euo pipefail

WORK="/home/student/dojo/02-file-ops"
cd "$WORK"

mkdir -p contracts/2023 contracts/2024 contracts/2025

mv raw_contracts/*2023.pdf contracts/2023/
mv raw_contracts/*2024.pdf contracts/2024/
mv raw_contracts/*2025.pdf contracts/2025/

mv contracts/2024/client_katmandu_2024.pdf contracts/2024/client_kathmandu_2024.pdf

rm -rf raw_contracts

ln -s config-2025.yaml config-current.yaml
ln config-2025.yaml config-backup.yaml

rm config-2025.yaml

sed -i 's/^q1_surviving_link_type:.*/q1_surviving_link_type: config-backup.yaml/' answers.txt
sed -i 's/^q2_survivor_link_count:.*/q2_survivor_link_count: 1/' answers.txt
