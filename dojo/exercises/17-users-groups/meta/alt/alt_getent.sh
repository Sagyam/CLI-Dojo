#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/17-users-groups}"
cd "$WORK"

# 1. Target UID via getent
TARGET=$(cat TARGET_USER.txt)
TARGET_UID=$(getent passwd "$TARGET" | cut -d: -f3)
sed -i "s/^q1_target_user_uid:.*/q1_target_user_uid: ${TARGET_UID}/" answers.txt

# 2. Count real shells via awk
REAL_SHELLS=$(getent passwd | awk -F: '$7 !~ /(nologin|false|sync)$/ {count++} END {print count}')
sed -i "s/^q2_real_shell_count:.*/q2_real_shell_count: ${REAL_SHELLS}/" answers.txt

# 3. Non-root user in sudo
SUDO_USER=$(getent group sudo | awk -F: '{print $4}' | tr ',' '\n' | grep -v '^root$' | head -n 1)
sed -i "s/^q3_sudo_user:.*/q3_sudo_user: ${SUDO_USER}/" answers.txt

# 4. GID of billing group
BILLING_GID=$(getent group billing | awk -F: '{print $3}')
sed -i "s/^q4_billing_gid:.*/q4_billing_gid: ${BILLING_GID}/" answers.txt

# 5. Passwd shell field number
sed -i "s/^q5_passwd_shell_field_number:.*/q5_passwd_shell_field_number: 7/" answers.txt

# 6. Switch to tara and write proof
TARA_PASS=$(awk '/Temporary Login Password:/ {print $NF}' HR_NOTE.txt)
python3 -c "import pty, os, time
master, slave = pty.openpty()
pid = os.fork()
if pid == 0:
    os.close(master)
    os.dup2(slave, 0)
    os.dup2(slave, 1)
    os.dup2(slave, 2)
    os.execlp('su', 'su', '-', 'tara', '-c', 'id > /home/tara/proof.txt')
else:
    os.close(slave)
    time.sleep(0.2)
    os.write(master, b'${TARA_PASS}\n')
    os.waitpid(pid, 0)
"
