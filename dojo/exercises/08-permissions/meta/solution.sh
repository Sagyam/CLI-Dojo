#!/usr/bin/env bash
# Canonical reference solution for 08-permissions (octal modes)
set -euo pipefail

WORK="/home/student/dojo/08-permissions"
cd "$WORK"

chgrp billing dropbox
chmod 2770 dropbox

chmod 750 deploy.sh
chmod 400 secret-salaries.csv

mkdir -p shared-tmp
chmod 1777 shared-tmp

OCTAL=$(cat .octal_answer)
sed -i "s/^q1_octal_mode:.*/q1_octal_mode: ${OCTAL}/" answers.txt
sed -i "s/^q2_umask_for_640:.*/q2_umask_for_640: 027/" answers.txt
