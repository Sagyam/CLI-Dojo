#!/usr/bin/env bash
# Reference solution for 13-log-capstone
set -euo pipefail

WORK="${WORK:-/home/student/dojo/13-log-capstone}"
cd "$WORK"

# 1. Top 5 client IPs
awk '{print $1}' access.log | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | sort | uniq -c | sort -nr | head -n 5 | awk '{print $1 "\t" $2}' > top5-ips.txt

# 2. 5xx errors by hour
awk '$9 >= 500 && $9 < 600 {
    split($4, a, ":")
    hour = a[2]
    if (length(hour) == 2) errs[hour]++
} END {
    for (h in errs) if (errs[h] > 0) print h "\t" errs[h]
}' access.log | sort > errors-by-hour.txt

# 3. Answers calculations
TOTAL_5XX=$(awk '$9 >= 500 && $9 < 600 {c++} END {print c+0}' access.log)
BUSIEST_HOUR=$(awk '{split($4, a, ":"); if (length(a[2])==2) reqs[a[2]]++} END {max=0; b=""; for (h in reqs) if (reqs[h]>max){max=reqs[h]; b=h} print b}' access.log)
OVERSIZED=$(awk '$10 > 1048576 {c++} END {print c+0}' access.log)

sed -i "s/^q1_total_5xx:.*/q1_total_5xx: ${TOTAL_5XX}/" answers.txt
sed -i "s/^q2_busiest_hour:.*/q2_busiest_hour: ${BUSIEST_HOUR}/" answers.txt
sed -i "s/^q3_oversized_requests:.*/q3_oversized_requests: ${OVERSIZED}/" answers.txt

# 4. General report script
cat > report.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
INPUT="${1:-}"
if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
    exit 0
fi
awk '{print $1}' "$INPUT" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | sort | uniq -c | sort -nr | head -n 5 | awk '{print $1 "\t" $2}'
EOF
chmod +x report.sh
