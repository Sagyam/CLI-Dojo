#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/14-archives}"
cd "$WORK"

# 1. List contents
VAULT_TAR=$(find vault -name "backup-*.tar.gz" | head -n 1)
tar -ztvf "$VAULT_TAR" | awk '{print $NF}' > contents.txt

# 2. Extract radius.conf using --strip-components=2 into etc/radius/
tar -xzf "$VAULT_TAR" --strip-components=2 -C etc/radius "etc/radius/radius.conf"

# 3. Create backup using tar -I zstd
tar -I zstd -cf backup-today.tar.zst -C etc --exclude='*.log' .

# 4. Answers
SHA=$(sha256sum etc/radius/radius.conf | awk '{print $1}')
sed -i "s/^q1_radius_sha256:.*/q1_radius_sha256: ${SHA}/" answers.txt
