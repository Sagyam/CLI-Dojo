#!/usr/bin/env bash
# Setup for 19-disk (The 92% Root Partition)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/19-disk}"
mkdir -p "$WORK"
cd "$WORK"

# 1. Kill any existing log writer processes
pkill -9 -f "yeti-log-writer" 2>/dev/null || true

# 2. Clean previous artifacts
rm -rf disk-arena top3-dirs.txt answers.txt

# 3. Create simulated disk arena directory structure
mkdir -p disk-arena/logs disk-arena/backups disk-arena/cache disk-arena/tmp

# Function to generate non-sparse chunk of real text using python3
gen_chunk() {
    local target="$1"
    local size_mb="$2"
    local bytes=$(( size_mb * 1024 * 1024 ))
    python3 -c "import sys; open(sys.argv[1], 'wb').write(b'2026-08-20T03:00:00Z [INFO] yeti-core-event: latency=42ms bytes=1024\n' * (int(sys.argv[2]) // 68))" "$target" "$bytes"
}

# 12 MB in logs (rank 1)
gen_chunk disk-arena/logs/router-01.log 6
gen_chunk disk-arena/logs/router-02.log 6

# 7 MB in backups (rank 2)
gen_chunk disk-arena/backups/dump-yesterday.sql 7

# 3 MB in cache (rank 3)
gen_chunk disk-arena/cache/asset-bundle-01.cache 2
gen_chunk disk-arena/cache/asset-bundle-02.cache 1

# 500 KB in tmp (rank 4)
gen_chunk disk-arena/tmp/session-scratch.tmp 1

# 5 MB giant active log file
gen_chunk disk-arena/app.log 5

# Ensure student ownership of the workdir before spawning writer
if command -v gosu >/dev/null 2>&1 && [[ "$(id -u)" -eq 0 ]] && id student >/dev/null 2>&1; then
    chown -R student:student "$WORK"
fi

# 4. Launch persistent background log writer holding app.log open
run_as_student() {
    local cmd="$1"
    if command -v gosu >/dev/null 2>&1 && [[ "$(id -u)" -eq 0 ]] && id student >/dev/null 2>&1; then
        gosu student bash -c "$cmd" </dev/null >/dev/null 2>&1 &
        local pid=$!
        disown "$pid" 2>/dev/null || true
    else
        bash -c "$cmd" </dev/null >/dev/null 2>&1 &
        local pid=$!
        disown "$pid" 2>/dev/null || true
    fi
}

run_as_student "cd '${WORK}' && exec -a yeti-log-writer bash -c '
while true; do
    echo \"[$(date -u +%FT%TZ)] yeti-live-stream: packet_count=120\" >> disk-arena/app.log
    sleep 0.5
done
'"

# 5. Create answer template
cat > answers.txt << 'EOF'
# YetiLink ticket 19 — answer sheet. Fill values after each colon.
q1_fullest_mount: 
q2_rm_open_file_reason: 
EOF
