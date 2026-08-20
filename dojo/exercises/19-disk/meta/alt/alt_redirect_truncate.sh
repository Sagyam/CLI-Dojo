#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/19-disk}"
cd "$WORK"

# 1. Top 3 largest directories using du -d 1
du -d 1 disk-arena | sort -rn | grep -v 'disk-arena$' | head -n 3 | awk '{print $2}' | sed 's|disk-arena/||' > top3-dirs.txt

# 2. Delete cache directory
rm -rf disk-arena/cache/

# 3. Truncate using shell redirection
: > disk-arena/app.log

# 4. Answers
sed -i "s|^q1_fullest_mount:.*|q1_fullest_mount: /var/log/|" answers.txt
sed -i "s/^q2_rm_open_file_reason:.*/q2_rm_open_file_reason: c/" answers.txt
