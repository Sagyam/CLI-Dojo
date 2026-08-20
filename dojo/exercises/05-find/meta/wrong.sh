#!/usr/bin/env bash
# Deliberately incorrect attempt for 05-find (over-deletes all tmp files including recent ones)
set -euo pipefail

WORK="/home/student/dojo/05-find"
cd "$WORK"

# Deletes ALL tmp files regardless of age (violates constraint)
find storage -type f -name "*.tmp" -delete

echo "storage/fake.txt" > big-files.txt
echo "storage/fake.txt" > insecure.txt

sed -i "s/^q1_deleted_old_tmp_count:.*/q1_deleted_old_tmp_count: 0/" answers.txt
