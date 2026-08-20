#!/usr/bin/env bash
# Deliberately incorrect attempt for 02-file-ops
set -euo pipefail

WORK="/home/student/dojo/02-file-ops"
cd "$WORK"

# Incorrect: delete contracts without sorting
rm -rf raw_contracts

# Incorrect link targets
ln -s /tmp/fake.yaml config-current.yaml
echo "wrong" > config-backup.yaml

printf "q1_surviving_link_type: symlink\nq2_survivor_link_count: 2\n" > answers.txt
