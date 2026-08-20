#!/usr/bin/env bash
# Canonical reference solution for 00-orientation
set -euo pipefail

WORK="/home/student/dojo/00-orientation"
mkdir -p "$WORK"

whoami > "${WORK}/hello.txt"
sed -i 's/^q1_hostname:.*/q1_hostname: yetilink-ops-01/' "${WORK}/answers.txt"

# Reveal hint
dojo hint 00 >/dev/null 2>&1 || true
