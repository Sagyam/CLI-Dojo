#!/usr/bin/env bash
# Alternative solution for 02-file-ops (using cp + rm instead of mv)
set -euo pipefail

WORK="/home/student/dojo/02-file-ops"
cd "$WORK"

mkdir -p contracts/2023 contracts/2024 contracts/2025

for f in raw_contracts/*2023.pdf; do
    cp "$f" contracts/2023/
    rm "$f"
done

for f in raw_contracts/*2024.pdf; do
    cp "$f" contracts/2024/
    rm "$f"
done

for f in raw_contracts/*2025.pdf; do
    cp "$f" contracts/2025/
    rm "$f"
done

cp contracts/2024/client_katmandu_2024.pdf contracts/2024/client_kathmandu_2024.pdf
rm contracts/2024/client_katmandu_2024.pdf

rm -rf raw_contracts

ln -s config-2025.yaml config-current.yaml
ln config-2025.yaml config-backup.yaml

rm config-2025.yaml

printf "q1_surviving_link_type: hardlink\nq2_survivor_link_count: 1\n" > answers.txt
