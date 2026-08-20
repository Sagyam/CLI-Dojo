#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/14-archives}"
cd "$WORK"

# 1. List archive contents
VAULT_TAR=$(find vault -name "backup-*.tar.gz" | head -n 1)
tar -ztf "$VAULT_TAR" > contents.txt

# 2. Extract entire archive to a temporary folder, then copy radius.conf
TMP_DIR=$(mktemp -d /tmp/dojo_restore.XXXXXX)
tar -xzf "$VAULT_TAR" -C "$TMP_DIR"
cp "${TMP_DIR}/etc/radius/radius.conf" etc/radius/radius.conf
rm -rf "$TMP_DIR"

# 3. Create zstd archive with --directory flag and glob exclusion
tar --directory=etc --exclude="*.log" -caf backup-today.tar.zst .

# 4. Record sha256
SHA=$(sha256sum etc/radius/radius.conf | cut -d' ' -f1)
sed -i "s/^q1_radius_sha256:.*/q1_radius_sha256: ${SHA}/" answers.txt
