#!/usr/bin/env bash
# Setup for 12-awk (The Latency Ledger)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/12-awk}"
mkdir -p "$WORK"

PINGS_LOG="${WORK}/pings.log"
USAGE_CSV="${WORK}/usage.csv"

python3 -c "
import random
random.seed(${SEED})

hosts = [
    'core-sw01', 'core-sw02', 'dist-sw01', 'dist-sw02',
    'edge-rtr01', 'edge-rtr02', 'border-gw01', 'border-gw02',
    'access-ap01', 'access-ap02'
]

# 1. Generate pings.log (~180 rows)
ping_lines = []
for i in range(1, 181):
    timestamp = f'2026-08-19T{i//60:02d}:{i%60:02d}:{i%59:02d}Z'
    host = hosts[i % len(hosts)]
    
    # Intentionally insert exact 100ms boundaries on specific rows
    if i in [15, 45, 95]:
        latency = 100
    elif host in ['edge-rtr02', 'access-ap02', 'dist-sw01']:
        latency = random.randint(105, 260)
    else:
        latency = random.randint(12, 85)
        
    ping_lines.append(f'{timestamp} {host} {latency}')

with open('${PINGS_LOG}', 'w') as f:
    for line in ping_lines:
        f.write(line + '\n')

# 2. Generate usage.csv (~60 rows)
plans = ['enterprise', 'pro', 'starter', 'ultra']
names = [
    'AlphaTech', 'BetaBytes', 'CloudPeak', 'DeltaData', 'EchoSystems',
    'FoxtrotNet', 'GammaGrid', 'HimalLogic', 'IndusWave', 'JunctionX'
]

rows = []
for i in range(1, 61):
    cid = f'CUST-{1000 + (i % len(names))}'
    cname = names[i % len(names)]
    cplan = plans[i % len(plans)]
    gb = random.randint(30, 800)
    rows.append(f'{cid},{cname},{cplan},{gb}')

with open('${USAGE_CSV}', 'w') as f:
    f.write('customer_id,name,plan,gb_used\n')
    for row in rows:
        f.write(row + '\n')
"

cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 12 — answer sheet. Fill values after each colon.
q1_avg_latency: 
q2_high_latency_count: 
EOF
