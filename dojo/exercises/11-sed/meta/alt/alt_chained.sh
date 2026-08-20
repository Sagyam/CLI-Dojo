#!/usr/bin/env bash
# Alternative solution for 11-sed using chained expressions
set -euo pipefail

WORK="${WORK:-/home/student/dojo/11-sed}"
cd "$WORK"

# 1 & 2: Chained sed with -e and -i.bak
sed -i.bak -e 's/\bblr1\.yetilink\.internal\b/ktm2.yetilink.internal/g' -e '/use_flannel/d' configs/*.conf

# 3: Comment out using replacement pattern
sed -i 's/.*deprecated_module.*/# &/' nginx.conf

# 4: Line range extraction
sed -n '10,20p' nginx.conf > preview.txt
