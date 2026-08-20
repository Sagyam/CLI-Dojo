#!/usr/bin/env bash
# Canonical reference solution for 05-find (using -delete)
set -euo pipefail

WORK="/home/student/dojo/05-find"
cd "$WORK"

OLD_COUNT=$(find storage -type f -name "*.tmp" -mtime +7 | wc -l)
sed -i "s/^q1_deleted_old_tmp_count:.*/q1_deleted_old_tmp_count: ${OLD_COUNT}/" answers.txt

find storage -type f -name "*.tmp" -mtime +7 -delete
find storage -type f -size +10M | LC_ALL=C sort > big-files.txt
find storage -type f -perm -002 | LC_ALL=C sort > insecure.txt
find storage -depth -type d -empty -delete
