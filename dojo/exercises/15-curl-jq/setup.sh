#!/usr/bin/env bash
# Setup for 15-curl-jq (Talking to the Customer API)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/15-curl-jq}"
mkdir -p "$WORK"
cd "$WORK"

# 1. Kill any existing instances of server.py
if [[ -f "/tmp/dojo_15_server.pid" ]]; then
    OLD_PID=$(cat "/tmp/dojo_15_server.pid" 2>/dev/null || true)
    if [[ -n "$OLD_PID" ]]; then
        kill -9 "$OLD_PID" 2>/dev/null || true
    fi
    rm -f "/tmp/dojo_15_server.pid"
fi
pkill -9 -f "15-curl-jq/server.py" 2>/dev/null || true

# 2. Select seeded port and start API server
PORT=$(seeded_int 8800 8899)
echo "$PORT" > API_PORT

SERVER_SCRIPT="${SCRIPT_DIR}/server.py"
python3 "$SERVER_SCRIPT" "$PORT" "$SEED" </dev/null >/dev/null 2>&1 &
SERVER_PID=$!
disown "$SERVER_PID" 2>/dev/null || true
echo "$SERVER_PID" > "/tmp/dojo_15_server.pid"
echo "$SERVER_PID" > .server_pid

# 3. Wait up to 2 seconds for server to be responsive
for i in {1..20}; do
    if curl -s "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

# 4. Clean previous student outputs
rm -f health.json names.txt premium.txt

# 5. Create answer template
cat > answers.txt << 'EOF'
# YetiLink ticket 15 — answer sheet. Fill values after each colon.
q1_post_status_unauth: 
q2_post_status_auth: 
q3_customer_count: 
EOF
