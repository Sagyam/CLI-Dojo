#!/usr/bin/env bash
# Setup for 13-log-capstone (The 3 AM Access Log)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/13-log-capstone}"
mkdir -p "$WORK"

ACCESS_LOG="${WORK}/access.log"

python3 -c "
import random
random.seed(${SEED})

top_ips = [
    '203.0.113.10',
    '203.0.113.25',
    '198.51.100.77',
    '192.0.2.144',
    '203.0.113.89'
]

other_ips = [f'10.10.{random.randint(1, 20)}.{random.randint(1, 254)}' for _ in range(50)]

endpoints = [
    '/index.html', '/api/v1/status', '/products/promo', '/checkout',
    '/static/css/main.css', '/static/js/app.js', '/assets/banner.png'
]

user_agents = [
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15',
    'YetiBot/1.0 (+http://yetilink.internal/bot)'
]

lines = []

# Generate distinct request volumes for top 5 IPs
top_counts = [12000 + random.randint(100, 500),
              9000 + random.randint(100, 500),
              7000 + random.randint(100, 500),
              5000 + random.randint(100, 500),
              3500 + random.randint(100, 500)]

for ip, count in zip(top_ips, top_counts):
    for _ in range(count):
        hour = random.choice(['03', '03', '03', f'{random.randint(0, 23):02d}'])
        minute = f'{random.randint(0, 59):02d}'
        second = f'{random.randint(0, 59):02d}'
        ep = random.choice(endpoints)
        ua = random.choice(user_agents)
        
        # 5xx spike heavily at hour 03
        if hour == '03' and random.random() < 0.45:
            status = random.choice([500, 502, 503, 504])
            size = random.randint(200, 800)
        else:
            status = random.choice([200, 200, 200, 304, 404])
            size = random.randint(1200, 85000)

        lines.append(f'{ip} - - [19/Aug/2026:{hour}:{minute}:{second} +0000] \"GET {ep} HTTP/1.1\" {status} {size} \"https://yetilink.internal/\" \"{ua}\"')

# Generate baseline traffic across all 24 hours
for _ in range(35000):
    ip = random.choice(other_ips)
    hour = f'{random.randint(0, 23):02d}'
    minute = f'{random.randint(0, 59):02d}'
    second = f'{random.randint(0, 59):02d}'
    ep = random.choice(endpoints)
    ua = random.choice(user_agents)

    if hour == '03' and random.random() < 0.35:
        status = random.choice([500, 502, 503])
        size = random.randint(200, 800)
    elif hour in ['01', '14', '22'] and random.random() < 0.02:
        status = random.choice([500, 503])
        size = random.randint(200, 800)
    else:
        status = random.choice([200, 200, 301, 304, 403, 404])
        size = random.randint(800, 45000)

    lines.append(f'{ip} - - [19/Aug/2026:{hour}:{minute}:{second} +0000] \"GET {ep} HTTP/1.1\" {status} {size} \"https://yetilink.internal/\" \"{ua}\"')

# Add seeded oversized responses (>1MB = >1048576)
oversized_count = random.randint(12, 28)
for i in range(oversized_count):
    ip = random.choice(other_ips)
    hour = f'{random.randint(0, 23):02d}'
    minute = f'{random.randint(0, 59):02d}'
    second = f'{random.randint(0, 59):02d}'
    size = 1048576 + random.randint(5000, 2000000)
    lines.append(f'{ip} - - [19/Aug/2026:{hour}:{minute}:{second} +0000] \"GET /dumps/backup.tar HTTP/1.1\" 200 {size} \"-\" \"YetiBackup/1.0\"')

# Add occasional malformed lines
lines.append('*** PROXY READ TIMEOUT DETECTED ***')
lines.append('2026-08-19 03:15:10 [ALERT] upstream server 127.0.0.1:8080 failed')
lines.append('GARBAGE LINE 12345')

random.shuffle(lines)

with open('${ACCESS_LOG}', 'w') as f:
    for l in lines:
        f.write(l + '\n')
"

cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 13 — answer sheet. Fill values after each colon.
q1_total_5xx: 
q2_busiest_hour: 
q3_oversized_requests: 
EOF
