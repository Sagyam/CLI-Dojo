#!/usr/bin/env bash
# Setup for 07-pipes (Streams, Split and Tamed)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/07-pipes}"
mkdir -p "$WORK"

TAG_OUT="STDOUT_$(seeded_hex 6)"
TAG_ERR="STDERR_$(seeded_hex 6)"
EXIT_CODE=$(seeded_int 7 42)

cat > "${WORK}/noisy-backup.sh" << EOF
#!/usr/bin/env bash
# Legacy YetiLink backup script emitting mixed stdout and stderr
echo "[${TAG_OUT}] Initializing file catalog scan..."
echo "[${TAG_ERR}] WARNING: /var/cache/app.sock unavailable" >&2
echo "[${TAG_OUT}] Archiving /etc/yetilink configuration..."
echo "[${TAG_ERR}] ERROR: Connection timeout syncing to s3://backup-vault" >&2
echo "[${TAG_OUT}] Dump completed with warnings."
exit ${EXIT_CODE}
EOF
chmod +x "${WORK}/noisy-backup.sh"

# Hidden fixture for executable grading
FIXTURES_DIR="${SCRIPT_DIR}/meta/fixtures"
mkdir -p "$FIXTURES_DIR"
cat > "${FIXTURES_DIR}/hidden-noisy.sh" << 'EOF'
#!/usr/bin/env bash
echo "[HIDDEN_STDOUT] Standard output line 1"
echo "[HIDDEN_STDERR] Standard error warning 1" >&2
echo "[HIDDEN_STDOUT] Standard output line 2"
exit 3
EOF
chmod +x "${FIXTURES_DIR}/hidden-noisy.sh"

cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 07 — answer sheet. Fill values after each colon.
q1_script_exit_code: 
EOF
