#!/usr/bin/env bash
# Alternative solution for 08-permissions (symbolic mode modifications)
set -euo pipefail

WORK="/home/student/dojo/08-permissions"
cd "$WORK"

chgrp billing dropbox
chmod u=rwx,g=rwxs,o= dropbox

chmod u=rwx,g=rx,o= deploy.sh
chmod u=r,g=,o= secret-salaries.csv

mkdir -p shared-tmp
chmod a=rwx,+t shared-tmp

OCTAL=$(cat .octal_answer)
printf "q1_octal_mode: %s\nq2_umask_for_640: 0027\n" "$OCTAL" > answers.txt
