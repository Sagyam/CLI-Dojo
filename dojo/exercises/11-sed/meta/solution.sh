#!/usr/bin/env bash
# Reference solution for 11-sed
set -euo pipefail

WORK="${WORK:-/home/student/dojo/11-sed}"
cd "$WORK"

# 1. Replace exact hostname with .bak backup
sed -i.bak 's/\bblr1\.yetilink\.internal\b/ktm2.yetilink.internal/g' configs/*.conf

# 2. Delete deprecated use_flannel lines
sed -i '/use_flannel/d' configs/*.conf

# 3. Comment out deprecated modules in nginx.conf
sed -i '/deprecated_module/s/^/# /' nginx.conf

# 4. Extract lines 10 to 20 to preview.txt
sed -n '10,20p' nginx.conf > preview.txt
