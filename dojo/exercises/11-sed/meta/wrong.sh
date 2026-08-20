#!/usr/bin/env bash
# Flawed attempt: naive substitution without word boundaries, corrupts decoys and forgets .bak
set -euo pipefail

WORK="${WORK:-/home/student/dojo/11-sed}"
cd "$WORK"

# Flaw 1: No .bak extension and no \b word boundary (corrupts node_blr1 and blr1..._backup)
sed -i 's/blr1.yetilink.internal/ktm2.yetilink.internal/g' configs/*.conf

# Flaw 2: Deletes flannel lines
sed -i '/use_flannel/d' configs/*.conf

# Flaw 3: Comments out with // instead of #
sed -i '/deprecated_module/s|^|// |' nginx.conf

# Flaw 4: Off-by-one line range (10,19p)
sed -n '10,19p' nginx.conf > preview.txt
