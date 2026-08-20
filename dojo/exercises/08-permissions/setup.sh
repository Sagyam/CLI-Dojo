#!/usr/bin/env bash
# Setup for 08-permissions (The Billing Drop-Box)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/08-permissions}"
mkdir -p "$WORK"

# 1. Create dropbox with standard wrong mode
mkdir -p "${WORK}/dropbox"
chmod 755 "${WORK}/dropbox"
if getent group ops >/dev/null 2>&1; then
    chgrp ops "${WORK}/dropbox" 2>/dev/null || true
fi

# 2. Deploy script
cat > "${WORK}/deploy.sh" << 'EOF'
#!/usr/bin/env bash
echo "Deploying YetiLink billing service..."
EOF
chmod 644 "${WORK}/deploy.sh"

# 3. Secret salaries
echo "employee,salary_npr" > "${WORK}/secret-salaries.csv"
echo "suresh,150000" >> "${WORK}/secret-salaries.csv"
echo "anita,140000" >> "${WORK}/secret-salaries.csv"
chmod 666 "${WORK}/secret-salaries.csv"

# 4. Octal quiz string generator (seeded)
OCTAL_MODES=(
    "751:-rwxr-x--x"
    "651:-rw-r-x--x"
    "740:-rwxr-----"
    "640:-rw-r-----"
    "754:-rwxr-xr--"
    "664:-rw-rw-r--"
)
PICKED_PAIR=$(seeded_pick "${OCTAL_MODES[@]}")
OCTAL_NUM=$(echo "$PICKED_PAIR" | cut -d: -f1)
OCTAL_STR=$(echo "$PICKED_PAIR" | cut -d: -f2)

# Save the picked quiz string for README display / answers
echo "$OCTAL_NUM" > "${WORK}/.octal_answer"
echo "$OCTAL_STR" > "${WORK}/.octal_string"

cat > "${WORK}/answers.txt" << EOF
# YetiLink ticket 08 — answer sheet. Fill values after each colon.
# Convert this ls -l mode to 3-digit octal: ${OCTAL_STR}
q1_octal_mode: 
q2_umask_for_640: 
EOF
