#!/usr/bin/env bash
# Deliberately incorrect attempt for 00-orientation
set -euo pipefail

WORK="/home/student/dojo/00-orientation"
mkdir -p "$WORK"

echo "root" > "${WORK}/hello.txt"
sed -i 's/^q1_hostname:.*/q1_hostname: wrong-host/' "${WORK}/answers.txt"
