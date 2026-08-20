#!/usr/bin/env bash
# Setup for 02-file-ops (The Great Shared-Drive Cleanup)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/02-file-ops}"
mkdir -p "$WORK"

# 1. Create messy raw_contracts folder
RAW="${WORK}/raw_contracts"
mkdir -p "$RAW"

# Create valid client files for years 2023, 2024, 2025
CLIENTS=("alpha" "beta" "gamma" "delta" "everest" "pokhara")
for client in "${CLIENTS[@]}"; do
    echo "Contract terms for $client 2023" > "${RAW}/client_${client}_2023.pdf"
    echo "Contract terms for $client 2024" > "${RAW}/client_${client}_2024.pdf"
    echo "Contract terms for $client 2025" > "${RAW}/client_${client}_2025.pdf"
done

# Misspelled file
echo "Kathmandu ISP agreement" > "${RAW}/client_katmandu_2024.pdf"

# Junk files to delete
echo "scratch" > "${RAW}/temp_scratch_1.tmp"
echo "scratch" > "${RAW}/temp_scratch_2.tmp"
echo "junk" > "${RAW}/.DS_Store"
echo "backup junk" > "${RAW}/junk_dump.bak"

# 2. Config files in root workdir
echo "yeti_config_version: 2024" > "${WORK}/config-2024.yaml"
echo "yeti_config_version: 2025-active-prod" > "${WORK}/config-2025.yaml"

# 3. Answer sheet template
cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 02 — answer sheet. Fill values after each colon.
q1_surviving_link_type: 
q2_survivor_link_count: 
EOF
