#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/17-users-groups}"
cd "$WORK"

# Wrong attempt:
# 1. Counts ALL lines in /etc/passwd including nologin
TOTAL_ACCOUNTS=$(wc -l < /etc/passwd)
sed -i "s/^q1_target_user_uid:.*/q1_target_user_uid: 99999/" answers.txt
sed -i "s/^q2_real_shell_count:.*/q2_real_shell_count: ${TOTAL_ACCOUNTS}/" answers.txt
sed -i "s/^q3_sudo_user:.*/q3_sudo_user: root/" answers.txt
sed -i "s/^q4_billing_gid:.*/q4_billing_gid: 1/" answers.txt
sed -i "s/^q5_passwd_shell_field_number:.*/q5_passwd_shell_field_number: 1/" answers.txt

# 2. Creates proof.txt as student instead of tara
mkdir -p /home/tara 2>/dev/null || true
id > /home/tara/proof.txt 2>/dev/null || true
