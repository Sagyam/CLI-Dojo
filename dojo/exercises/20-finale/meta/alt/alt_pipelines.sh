#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/20-finale}"
cd "$WORK"

# Ticket 1: Truncate via shell redirection
: > incident/app.log

# Ticket 2: Terminate stubborn process by PID
STUBBORN_PID=$(pgrep -f "^stubbornd" || true)
if [[ -n "$STUBBORN_PID" ]]; then
    kill -9 "$STUBBORN_PID" 2>/dev/null || true
fi

# Ticket 3: Find rogue config via find + grep
ROGUE_FILE=$(find incident/configs -type f -exec grep -l "198\.51\.100\." {} + | head -n 1)
echo "$ROGUE_FILE" > t3_rogue_file.txt
ROGUE_IP=$(awk -F= '/dns/ {gsub(/[[:space:]]/, ""); print $2}' "$ROGUE_FILE")
sed -i "s/^t3_rogue_val:.*/t3_rogue_val: ${ROGUE_IP}/" answers.txt

# Ticket 4: Fix permissions
chmod u=rw,g=r,o= incident/secure/billing.conf

# Ticket 5: Access log forensics via cut/sort
cut -d' ' -f1 incident/access.log | sort | uniq -c | sort -k1,1nr | head -n 3 | awk '{print $1 "\t" $2}' > t5_top3_ips.txt
TOTAL_5XX=$(grep -c -E ' HTTP/1\.[01]" 5[0-9]{2} ' incident/access.log)
sed -i "s/^t5_total_5xx:.*/t5_total_5xx: ${TOTAL_5XX}/" answers.txt

# Ticket 6: Package evidence using tar -czvf
tar -czvf evidence.tar.gz t3_rogue_file.txt t5_top3_ips.txt answers.txt
