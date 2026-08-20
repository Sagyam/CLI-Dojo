#!/usr/bin/env bash
# Setup for 20-finale (The Pager Goes Off)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/20-finale}"
mkdir -p "$WORK"
cd "$WORK"

# 1. Clean previous run state and kill running daemons
pkill -9 -f "^stubbornd" 2>/dev/null || true
pkill -9 -f "^yeti-authd" 2>/dev/null || true
pkill -9 -f "yeti-live-logger" 2>/dev/null || true

rm -rf incident t3_rogue_file.txt t5_top3_ips.txt answers.txt evidence.tar.gz .expected_*

mkdir -p incident/configs incident/secure

# --- Ticket 1: Active Log File ---
python3 -c "
with open('incident/app.log', 'wb') as f:
    f.write(b'2026-08-20T03:14:00Z [ALERT] disk bloat event chunk\n' * 80000)
"

# --- Ticket 2: Daemons ---
run_daemon() {
    local proc_name="$1"
    local trap_cmd="${2:-}"
    if command -v gosu >/dev/null 2>&1 && [[ "$(id -u)" -eq 0 ]] && id "student" >/dev/null 2>&1; then
        gosu student bash -c "exec -a \"$proc_name\" bash -c \"${trap_cmd} while true; do sleep 0.2; done\"" </dev/null >/dev/null 2>&1 &
        local pid=$!
        disown "$pid" 2>/dev/null || true
    else
        bash -c "exec -a \"$proc_name\" bash -c \"${trap_cmd} while true; do sleep 0.2; done\"" </dev/null >/dev/null 2>&1 &
        local pid=$!
        disown "$pid" 2>/dev/null || true
    fi
}

run_daemon "stubbornd" "trap '' TERM INT;"
run_daemon "yeti-authd" ""

# Logger daemon holding incident/app.log open
if command -v gosu >/dev/null 2>&1 && [[ "$(id -u)" -eq 0 ]] && id "student" >/dev/null 2>&1; then
    gosu student bash -c "cd '${WORK}' && exec -a yeti-live-logger bash -c 'while true; do echo \"[$(date -u +%FT%TZ)] metric stream\" >> incident/app.log; sleep 0.5; done'" </dev/null >/dev/null 2>&1 &
    LOGGER_PID=$!
    disown "$LOGGER_PID" 2>/dev/null || true
else
    bash -c "cd '${WORK}' && exec -a yeti-live-logger bash -c 'while true; do echo \"[$(date -u +%FT%TZ)] metric stream\" >> incident/app.log; sleep 0.5; done'" </dev/null >/dev/null 2>&1 &
    LOGGER_PID=$!
    disown "$LOGGER_PID" 2>/dev/null || true
fi

# --- Ticket 3: Configs with single rogue file ---
TOTAL_CONFIGS=60
ROGUE_IDX=$(( 10 + (SEED % 45) ))
ROGUE_OCTET=$(( 10 + (SEED % 80) ))
ROGUE_IP="198.51.100.${ROGUE_OCTET}"

for ((i=1; i<=TOTAL_CONFIGS; i++)); do
    FNAME="incident/configs/srv_$(printf "%03d" "$i").conf"
    if [[ $i -eq $ROGUE_IDX ]]; then
        cat > "$FNAME" << EOF
[server]
hostname = srv-$(printf "%03d" "$i").yetilink.internal
dns = ${ROGUE_IP}
gateway = 10.10.0.1
status = active
EOF
        echo "$FNAME" > .expected_rogue_file
        echo "$ROGUE_IP" > .expected_rogue_ip
    else
        cat > "$FNAME" << EOF
[server]
hostname = srv-$(printf "%03d" "$i").yetilink.internal
dns = 10.10.0.2
gateway = 10.10.0.1
status = active
EOF
    fi
done

# --- Ticket 4: Permissions Lockout ---
cat > incident/secure/billing.conf << EOF
# Sensitive Billing Configuration
DB_HOST=billing-db.yetilink.internal
DB_SECRET=yeti-sec-$(seeded_hex 16)
EOF

chmod 000 incident/secure/billing.conf

# --- Ticket 5: Access Log Forensics via Python generator ---
python3 -c "
import random, sys

seed = int(sys.argv[1])
rng = random.Random(seed)

ip_top1 = f'10.10.101.{rng.randint(2, 250)}'
ip_top2 = f'10.10.102.{rng.randint(2, 250)}'
ip_top3 = f'10.10.103.{rng.randint(2, 250)}'

total_5xx = rng.randint(22, 38)
count_5xx = 0

lines = []

# Top 1: 50 requests
for i in range(50):
    status = 200
    if count_5xx < total_5xx and i % 3 == 0:
        status = 500
        count_5xx += 1
    lines.append(f'{ip_top1} - - [20/Aug/2026:03:14:00 +0000] \"GET /api/v1/status HTTP/1.1\" {status} 1256 \"-\" \"curl/8.5.0\"')

# Top 2: 30 requests
for i in range(30):
    status = 200
    if count_5xx < total_5xx and i % 4 == 0:
        status = 502
        count_5xx += 1
    lines.append(f'{ip_top2} - - [20/Aug/2026:03:14:05 +0000] \"GET /api/v1/customers HTTP/1.1\" {status} 4820 \"-\" \"curl/8.5.0\"')

# Top 3: 20 requests
for i in range(20):
    status = 200
    if count_5xx < total_5xx and i % 3 == 0:
        status = 503
        count_5xx += 1
    lines.append(f'{ip_top3} - - [20/Aug/2026:03:14:10 +0000] \"POST /api/v1/notes HTTP/1.1\" {status} 340 \"-\" \"curl/8.5.0\"')

# Fill remaining 5xx errors
while count_5xx < total_5xx:
    noise_ip = f'10.10.205.{rng.randint(2, 250)}'
    lines.append(f'{noise_ip} - - [20/Aug/2026:03:14:15 +0000] \"GET /health HTTP/1.1\" 500 120 \"-\" \"curl/8.5.0\"')
    count_5xx += 1

# Additional noise requests
for i in range(15):
    noise_ip = f'10.10.206.{rng.randint(2, 250)}'
    lines.append(f'{noise_ip} - - [20/Aug/2026:03:14:20 +0000] \"GET /index.html HTTP/1.1\" 200 4500 \"-\" \"Mozilla/5.0\"')

with open('incident/access.log', 'w') as f:
    for line in lines:
        f.write(line + '\n')

with open('.expected_5xx', 'w') as f:
    f.write(str(total_5xx) + '\n')

with open('.expected_top3_ips', 'w') as f:
    f.write(f'50\t{ip_top1}\n30\t{ip_top2}\n20\t{ip_top3}\n')
" "$SEED"

# Ensure student ownership of workdir files
if id student >/dev/null 2>&1; then
    chown -R student:student "$WORK"
    chmod 000 incident/secure/billing.conf
fi

# Answer template
cat > answers.txt << 'EOF'
# YetiLink Ticket 20 Finale — Incident Investigation Answer Sheet
t3_rogue_val: 
t5_total_5xx: 
EOF
