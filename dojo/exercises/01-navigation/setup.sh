#!/usr/bin/env bash
# Setup for 01-navigation (The Scavenger Hunt)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/01-navigation}"
mkdir -p "$WORK"

# 1. Build FHS decoy tree
FAKEROOT="${WORK}/fake-root"
mkdir -p "${FAKEROOT}/etc/network" \
         "${FAKEROOT}/var/log/nginx" \
         "${FAKEROOT}/var/cache" \
         "${FAKEROOT}/usr/bin" \
         "${FAKEROOT}/opt/app/v1" \
         "${FAKEROOT}/opt/backup" \
         "${FAKEROOT}/tmp"

# 2. Seeded largest file under fake-root/var
# Generate random sized files in var
VAR_SIZES=(1024 2048 4096 8192 12345 16384)
# One guaranteed largest file
LARGEST_BYTES=$(seeded_int 25000 45000)
LARGEST_FILE="syslog.1"

head -c 1024 < /dev/zero | tr '\0' 'A' > "${FAKEROOT}/var/log/nginx/access.log"
head -c 4096 < /dev/zero | tr '\0' 'B' > "${FAKEROOT}/var/cache/apt.cache"
head -c 2048 < /dev/zero | tr '\0' 'C' > "${FAKEROOT}/var/log/dmesg"
head -c "$LARGEST_BYTES" < /dev/zero | tr '\0' 'X' > "${FAKEROOT}/var/log/${LARGEST_FILE}"

# 3. Disguised file (a valid 1x1 PNG disguised with .conf extension)
# Minimal valid 1x1 transparent PNG hex
PNG_HEX="89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c4890000000a49444154789c63000100000500010d0a2db40000000049454e44ae426082"
DISGUISED_CONF="${FAKEROOT}/etc/network/vpn-adapter.conf"
echo "$PNG_HEX" | xxd -r -p > "$DISGUISED_CONF" 2>/dev/null || printf "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xb4\x00\x00\x00\x00IEND\xaeB\`\x82" > "$DISGUISED_CONF"

# Other regular config files
echo "server_name yetilink.internal;" > "${FAKEROOT}/etc/nginx.conf"
echo "nameserver 10.10.0.53" > "${FAKEROOT}/etc/resolv.conf"

# 4. Hidden files in fake-root/opt/backup
HIDDEN_COUNT=$(seeded_int 3 6)
for ((i = 1; i <= HIDDEN_COUNT; i++)); do
    echo "archive $i" > "${FAKEROOT}/opt/backup/.secret_backup_${i}.tar"
done
echo "manifest" > "${FAKEROOT}/opt/backup/manifest.txt"

# 5. Deeply nested treasure file
TREASURE_DEPTH=$(seeded_pick "a/b/c" "x/y/z" "core/infra/vault" "ops/secrets/archive")
TREASURE_DIR="${FAKEROOT}/opt/app/v1/${TREASURE_DEPTH}"
mkdir -p "$TREASURE_DIR"
echo "GOLD{YETILINK_CLI_MASTER_$(seeded_hex 8)}" > "${TREASURE_DIR}/treasure.txt"

# 6. Template answers.txt
cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 01 — answer sheet. Fill values after each colon.
q1_treasure_path: 
q2_largest_var_bytes: 
q3_disguised_file_type: 
q4_hidden_file_count: 
q5_relative_path_choice: 
EOF
