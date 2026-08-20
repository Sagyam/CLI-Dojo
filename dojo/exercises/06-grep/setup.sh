#!/usr/bin/env bash
# Setup for 06-grep (The Rogue Resolver)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/06-grep}"
mkdir -p "$WORK"

CONFIG_DIR="${WORK}/configs"
mkdir -p "$CONFIG_DIR"

# Seeded rogue IP and location
ROGUE_IP="198.51.100.$(seeded_int 2 254)"
ROGUE_DIR_INDEX=$(seeded_int 1 20)
ROGUE_FILE_INDEX=$(seeded_int 1 400)

# Generate 8,000 small config files across 20 subdirectories
python3 -c "
import os, sys

config_dir = '${CONFIG_DIR}'
rogue_dir_idx = ${ROGUE_DIR_INDEX}
rogue_file_idx = ${ROGUE_FILE_INDEX}
rogue_ip = '${ROGUE_IP}'

for d in range(1, 21):
    dir_path = os.path.join(config_dir, f'cluster_{d:02d}')
    os.makedirs(dir_path, exist_ok=True)
    for f in range(1, 401):
        file_path = os.path.join(dir_path, f'node_{f:03d}.conf')
        is_rogue = (d == rogue_dir_idx and f == rogue_file_idx)
        with open(file_path, 'w') as out:
            out.write(f'# YetiLink Node Config {d}-{f}\n')
            out.write('interface eth0 up\n')
            out.write('mtu 1500\n')
            if is_rogue:
                out.write(f'nameserver {rogue_ip}\n')
            else:
                out.write('nameserver 10.10.0.53\n')
            out.write('gateway 10.10.0.1\n')
            out.write('keepalive 30\n')
"

# Auth log generation
AUTH_LOG="${WORK}/auth.log"
FAIL_COUNT=$(seeded_int 30 60)
UNIQUE_IPS_COUNT=$(seeded_int 6 10)

python3 -c "
import random
random.seed(${SEED})

fail_count = ${FAIL_COUNT}
unique_ips_count = ${UNIQUE_IPS_COUNT}

ip_pool = [f'192.168.1.{100 + i}' for i in range(unique_ips_count)]

lines = []
for i in range(1, fail_count + 1):
    ip = ip_pool[i % unique_ips_count]
    lines.append(f'2026-08-19T03:{i%60:02d}:10 yetilink-ops-01 sshd[1234]: Failed password for invalid user admin from {ip} port {20000+i} ssh2')

# Mix in legitimate lines
for i in range(1, 40):
    lines.append(f'2026-08-19T03:{i%60:02d}:25 yetilink-ops-01 sshd[5678]: Accepted publickey for student from 10.10.0.12 port {30000+i} ssh2')

random.shuffle(lines)

with open('${AUTH_LOG}', 'w') as out:
    for line in lines:
        out.write(line + '\n')
"

cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 06 — answer sheet. Fill values after each colon.
q1_rogue_file_path: 
q2_rogue_ip: 
q3_failed_login_lines: 
q4_unique_failing_ips: 
EOF
