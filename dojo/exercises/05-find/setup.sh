#!/usr/bin/env bash
# Setup for 05-find (Disk Janitor)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/05-find}"
mkdir -p "$WORK"

STORAGE="${WORK}/storage"
mkdir -p "${STORAGE}/logs" \
         "${STORAGE}/cache/v1" \
         "${STORAGE}/cache/v2" \
         "${STORAGE}/backups" \
         "${STORAGE}/users/anita" \
         "${STORAGE}/users/suresh" \
         "${STORAGE}/empty_archive" \
         "${STORAGE}/cache/v1/empty_sub"

# 1. Old tmp files (>7 days old)
OLD_TMP_COUNT=$(seeded_int 5 8)
for ((i = 1; i <= OLD_TMP_COUNT; i++)); do
    f="${STORAGE}/cache/v1/session_dump_${i}.tmp"
    echo "old cache data $i" > "$f"
    touch -d "12 days ago" "$f"
done

# 2. Recent tmp files (<=7 days old) - MUST SURVIVE
RECENT_TMP_COUNT=$(seeded_int 3 5)
for ((i = 1; i <= RECENT_TMP_COUNT; i++)); do
    f="${STORAGE}/cache/v2/active_session_${i}.tmp"
    echo "recent cache data $i" > "$f"
    touch -d "2 days ago" "$f"
done

# 3. Big files (>10MB sparse files)
BIG_COUNT=$(seeded_int 3 5)
for ((i = 1; i <= BIG_COUNT; i++)); do
    sz=$(seeded_int 12 25)
    f="${STORAGE}/backups/db_dump_${i}.sql"
    truncate -s "${sz}M" "$f"
done
# Small files (<=10MB)
truncate -s "4M" "${STORAGE}/backups/small_config.tar"
truncate -s "8M" "${STORAGE}/logs/archive.log"

# 4. World-writable regular files
echo "public notes" > "${STORAGE}/users/anita/shared_notes.txt"
chmod 777 "${STORAGE}/users/anita/shared_notes.txt"

echo "scratchpad" > "${STORAGE}/users/suresh/scratch.txt"
chmod 666 "${STORAGE}/users/suresh/scratch.txt"

# Secure files
echo "private key" > "${STORAGE}/users/suresh/id_rsa"
chmod 600 "${STORAGE}/users/suresh/id_rsa"

cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 05 — answer sheet. Fill values after each colon.
q1_deleted_old_tmp_count: 
EOF
