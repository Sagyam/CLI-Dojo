#!/usr/bin/env bash
# Alternative solution for 13-log-capstone using cut & sort pipelines
set -euo pipefail

WORK="${WORK:-/home/student/dojo/13-log-capstone}"
cd "$WORK"

# 1. Top 5 IPs
cut -d' ' -f1 access.log | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | sort | uniq -c | sort -k1,1nr | head -n 5 | awk '{print $1 "\t" $2}' > top5-ips.txt

# 2. 5xx errors by hour
grep -E ' "(GET|POST|PUT|DELETE|HEAD) [^"]+" 5[0-9]{2} ' access.log | cut -d'[' -f2 | cut -d: -f2 | sort | uniq -c | awk '{print $2 "\t" $1}' | sort -k1,1 > errors-by-hour.txt

# 3. Answers
TOTAL_5XX=$(grep -c -E ' "(GET|POST|PUT|DELETE|HEAD) [^"]+" 5[0-9]{2} ' access.log || true)
BUSIEST_HOUR=$(cut -d'[' -f2 access.log | cut -d: -f2 | grep -E '^[0-9]{2}$' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
OVERSIZED=$(awk '$10 > 1048576 {c++} END {print c+0}' access.log)

sed -i "s/^q1_total_5xx:.*/q1_total_5xx: ${TOTAL_5XX}/" answers.txt
sed -i "s/^q2_busiest_hour:.*/q2_busiest_hour: ${BUSIEST_HOUR}/" answers.txt
sed -i "s/^q3_oversized_requests:.*/q3_oversized_requests: ${OVERSIZED}/" answers.txt

# 4. report.sh
cat > report.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
INPUT="${1:-}"
if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
    exit 0
fi
cut -d' ' -f1 "$INPUT" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | sort | uniq -c | sort -k1,1nr | head -n 5 | awk '{print $1 "\t" $2}'
EOF
chmod +x report.sh
