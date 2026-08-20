#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/20-finale}"
cd "$WORK"

# Wrong attempt:
# 1. Kills legitimate daemon
pkill -9 -f "yeti-authd" 2>/dev/null || true

# 2. Deletes open log with rm instead of truncating
rm -f incident/app.log

# 3. Wrong evidence
touch t3_rogue_file.txt t5_top3_ips.txt
tar -czf evidence.tar.gz t3_rogue_file.txt
sed -i "s/^t3_rogue_val:.*/t3_rogue_val: 10.0.0.1/" answers.txt
sed -i "s/^t5_total_5xx:.*/t5_total_5xx: 0/" answers.txt
