#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/16-env-path}"
cd "$WORK"

# Wrong solution:
# Does not update ~/.zshrc
# Generates a fake/incorrect token file
echo "WRONG_TOKEN_12345" > token.txt
sed -i "s|^q1_first_path_dir:.*|q1_first_path_dir: /fake/path|" answers.txt
