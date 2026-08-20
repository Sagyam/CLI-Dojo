#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/20-finale}"
cd "$WORK"

# Ticket 1: Truncate open log
truncate -s 0 incident/app.log

# Ticket 2: Terminate stubborn process
pkill -9 -f "^stubbornd" 2>/dev/null || true

# Ticket 3: Find rogue config
ROGUE_FILE=$(grep -rl "198\.51\.100\." incident/configs/)
echo "$ROGUE_FILE" > t3_rogue_file.txt
ROGUE_IP=$(grep -oE '198\.51\.100\.[0-9]+' "$ROGUE_FILE" | head -n 1)
sed -i "s/^t3_rogue_val:.*/t3_rogue_val: ${ROGUE_IP}/" answers.txt

# Ticket 4: Fix permissions
chmod 640 incident/secure/billing.conf

# Ticket 5: Access log forensics
awk '{print $1}' incident/access.log | sort | uniq -c | sort -nr | head -n 3 | awk '{print $1 "\t" $2}' > t5_top3_ips.txt
TOTAL_5XX=$(awk '$9 ~ /^5[0-9]{2}$/ {count++} END {print count+0}' incident/access.log)
sed -i "s/^t5_total_5xx:.*/t5_total_5xx: ${TOTAL_5XX}/" answers.txt

# Ticket 6: Package evidence
tar -czf evidence.tar.gz t3_rogue_file.txt t5_top3_ips.txt answers.txt
