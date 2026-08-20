#!/usr/bin/env bash
# Setup for 17-users-groups (The Account Audit)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/17-users-groups}"
mkdir -p "$WORK"
cd "$WORK"

# 1. Clean previous audit users and files
userdel -r suresh_ops 2>/dev/null || true
userdel -r anita_lead 2>/dev/null || true
userdel -r svc_backup 2>/dev/null || true
userdel -r tara 2>/dev/null || true
rm -rf /home/tara
rm -f answers.txt TARGET_USER.txt HR_NOTE.txt .expected_tara_pass

# 2. Generate seeded IDs and credentials
UID_SURESH=$(( 1050 + (SEED % 40) ))
UID_ANITA=$(( 1150 + (SEED % 40) ))
UID_SVC=$(( 850 + (SEED % 40) ))
UID_TARA=$(( 1250 + (SEED % 40) ))
TARA_PASS="tara-$(seeded_word)-$(seeded_int 100 999)"

# 3. Create audit accounts
useradd -u "$UID_SURESH" -s /bin/bash -m -G sudo suresh_ops 2>/dev/null || true
useradd -u "$UID_ANITA" -s /usr/sbin/nologin -m anita_lead 2>/dev/null || true
useradd -u "$UID_SVC" -s /usr/sbin/nologin -M svc_backup 2>/dev/null || true
useradd -u "$UID_TARA" -s /bin/bash -m tara 2>/dev/null || true

echo "tara:${TARA_PASS}" | chpasswd
chmod 755 /home/tara
chown -R tara:tara /home/tara

# Ensure billing group exists
if ! getent group billing >/dev/null 2>&1; then
    groupadd billing
fi

# 4. Write ticket instructions & files
echo "suresh_ops" > TARGET_USER.txt
echo "$TARA_PASS" > .expected_tara_pass

cat > HR_NOTE.txt << EOF
======================================================
YetiLink HR Onboarding Memo — Systems Engineering
======================================================
Employee: Tara Adhikari
Username: tara
Temporary Login Password: ${TARA_PASS}

Action Item: Verify her account login via 'su - tara' and
record her identity by saving her 'id' command output to:
/home/tara/proof.txt
======================================================
EOF

cat > answers.txt << 'EOF'
# YetiLink ticket 17 — answer sheet. Fill values after each colon.
q1_target_user_uid: 
q2_real_shell_count: 
q3_sudo_user: 
q4_billing_gid: 
q5_passwd_shell_field_number: 
EOF
