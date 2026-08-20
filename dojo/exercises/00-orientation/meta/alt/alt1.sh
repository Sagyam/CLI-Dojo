#!/usr/bin/env bash
# Alternative solution for 00-orientation (using echo and hostname command substitution)
set -euo pipefail

WORK="/home/student/dojo/00-orientation"
mkdir -p "$WORK"

echo "student" > "${WORK}/hello.txt"
printf "q1_hostname: %s\n" "$(hostname)" > "${WORK}/answers.txt"

# Reveal hint
dojo hint 00 >/dev/null 2>&1 || true
