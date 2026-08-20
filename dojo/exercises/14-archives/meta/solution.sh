#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/14-archives}"
cd "$WORK"

# 1. List archive contents
VAULT_TAR=$(find vault -name "backup-*.tar.gz" | head -n 1)
tar -tf "$VAULT_TAR" > contents.txt

# 2. Extract only radius.conf into place
tar -xzf "$VAULT_TAR" etc/radius/radius.conf

# 3. Create tonight's backup excluding logs and with paths relative to etc/
tar --zstd -cf backup-today.tar.zst -C etc --exclude='*.log' .

# 4. Record sha256 in answers.txt
SHA=$(sha256sum etc/radius/radius.conf | awk '{print $1}')
sed -i "s/^q1_radius_sha256:.*/q1_radius_sha256: ${SHA}/" answers.txt
