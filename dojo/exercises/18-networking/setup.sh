#!/usr/bin/env bash
# Setup for 18-networking (Who's Listening?)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/18-networking}"
mkdir -p "$WORK"
cd "$WORK"

# 1. Kill any existing instances of network daemons
pkill -9 -f "yeti-billing-mock" 2>/dev/null || true
pkill -9 -f "yeti-rogue-dns" 2>/dev/null || true

# 2. Reset /etc/hosts to clean state and ensure student group can write
grep -v "billing\.yetilink\.internal" /etc/hosts > /tmp/hosts.clean && cat /tmp/hosts.clean > /etc/hosts && rm -f /tmp/hosts.clean
chmod 664 /etc/hosts
chgrp student /etc/hosts 2>/dev/null || true

# 3. Generate seeded ports & token
PORT_A=$(seeded_int 9100 9150)
PORT_B=$(seeded_int 9151 9200)
TOKEN="yeti-token-$(seeded_hex 12)"

echo "$PORT_A" > PORT_A.txt
echo "$PORT_B" > PORT_B.txt
echo "$TOKEN" > .expected_token

# 4. Clean previous student outputs
rm -f ports.txt hosts-proof.txt answers.txt

# 5. Start listeners as student user
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

run_as_student "exec -a yeti-billing-mock python3 -c '
import sys, json
from http.server import HTTPServer, BaseHTTPRequestHandler
class H(BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_GET(self):
        data = json.dumps({\"status\": \"billing_ok\", \"token\": \"${TOKEN}\", \"host\": \"billing.yetilink.internal\"}).encode()
        self.send_response(200)
        self.send_header(\"Content-Type\", \"application/json\")
        self.send_header(\"Content-Length\", str(len(data)))
        self.end_headers()
        self.wfile.write(data)
HTTPServer((\"0.0.0.0\", ${PORT_A}), H).serve_forever()
'"

run_as_student "exec -a yeti-rogue-dns python3 -c '
import socket, time
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((\"0.0.0.0\", ${PORT_B}))
s.listen(5)
while True:
    try:
        conn, _ = s.accept()
        conn.close()
    except Exception:
        time.sleep(0.1)
'"

# Wait briefly for sockets to bind
for i in {1..20}; do
    if ss -tln | grep -q ":${PORT_A} "; then
        break
    fi
    sleep 0.05
done

# 6. Create answer sheet template
cat > answers.txt << 'EOF'
# YetiLink ticket 18 — answer sheet. Fill values after each colon.
q1_portA_process: 
q2_container_ip: 
q3_privileged_ports_reason: 
EOF
