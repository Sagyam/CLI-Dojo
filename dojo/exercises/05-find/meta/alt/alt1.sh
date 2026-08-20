#!/usr/bin/env bash
# Alternative solution for 05-find (using -exec rm and rmdir)
set -euo pipefail

WORK="/home/student/dojo/05-find"
cd "$WORK"

OLD_FILES=$(find storage -type f -name "*.tmp" -mtime +7)
OLD_COUNT=$(echo "$OLD_FILES" | grep -c -v '^$' || true)
sed -i "s/^q1_deleted_old_tmp_count:.*/q1_deleted_old_tmp_count: ${OLD_COUNT}/" answers.txt

find storage -type f -name "*.tmp" -mtime +7 -exec rm -f {} +
find storage -type f -size +10M | LC_ALL=C sort > big-files.txt
find storage -type f -perm /002 | LC_ALL=C sort > insecure.txt
while find storage -type d -empty -print -delete | grep -q .; do :; done
