#!/usr/bin/env bash
# Setup for 10-columns (Top Talkers)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/10-columns}"
mkdir -p "$WORK"

USAGE_CSV="${WORK}/usage.csv"

python3 -c "
import random
random.seed(${SEED})

plans = ['starter', 'pro', 'enterprise', 'ultra']
names = [
    'AlphaTech', 'BetaBytes', 'CloudPeak', 'DeltaData', 'EchoSystems',
    'FoxtrotNet', 'GammaGrid', 'HimalLogic', 'IndusWave', 'JunctionX',
    'KoshiFiber', 'LhotseNet', 'MomoMakers', 'NexusOps', 'OrbitLink',
    'PatanPower', 'QuantumQ', 'RedShift', 'SagarmathaNet', 'ThamelTech'
]

# Generate 30 unique customer IDs
customer_ids = [f'CUST-{1000 + i}' for i in range(len(names))]

rows = []
# Ensure a solid top 5 with a deterministic tie at rank 5/6
top_gbs = [950 + random.randint(1, 40), 850 + random.randint(1, 40), 750 + random.randint(1, 40), 650 + random.randint(1, 40)]
tie_gb = 550 + random.randint(1, 30)
top_gbs.extend([tie_gb, tie_gb])

for i, gb in enumerate(top_gbs):
    cid = customer_ids[i]
    cname = names[i]
    cplan = plans[i % len(plans)]
    rows.append((cid, cname, cplan, gb))

# Generate remaining rows (with some duplicate customer IDs to test uniqueness)
for i in range(len(top_gbs), 65):
    idx = random.randint(0, len(customer_ids) - 1)
    cid = customer_ids[idx]
    cname = names[idx]
    cplan = random.choice(plans)
    gb = random.randint(20, 500)
    rows.append((cid, cname, cplan, gb))

random.shuffle(rows)

with open('${USAGE_CSV}', 'w') as f:
    f.write('customer_id,name,plan,gb_used\n')
    for cid, cname, cplan, gb in rows:
        f.write(f'{cid},{cname},{cplan},{gb}\n')
"

cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 10 — answer sheet. Fill values after each colon.
q1_unique_customers: 
q2_total_rows: 
EOF
