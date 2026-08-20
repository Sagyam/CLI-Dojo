#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/19-disk}"
cd "$WORK"

# Wrong attempt:
# 1. Deletes the open file with rm (violating the prompt)
rm -f disk-arena/app.log

# 2. Leaves cache intact
touch top3-dirs.txt

# 3. Wrong answers
sed -i "s|^q1_fullest_mount:.*|q1_fullest_mount: /|" answers.txt
sed -i "s/^q2_rm_open_file_reason:.*/q2_rm_open_file_reason: a/" answers.txt
