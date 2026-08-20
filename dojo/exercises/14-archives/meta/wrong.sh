#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/14-archives}"
cd "$WORK"

# Wrong attempt:
# 1. Extracts nothing / leaves corrupted radius.conf
# 2. Includes logs in backup
# 3. Archives with etc/ prefix (not relative within etc)
touch contents.txt
tar --zstd -cf backup-today.tar.zst etc/
sed -i "s/^q1_radius_sha256:.*/q1_radius_sha256: badhash1234567890/" answers.txt
