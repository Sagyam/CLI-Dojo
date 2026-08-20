#!/usr/bin/env bash
# Reference solution for 12-awk
set -euo pipefail

WORK="${WORK:-/home/student/dojo/12-awk}"
cd "$WORK"

# 1. Average latency and >100ms count
AVG_LAT=$(awk '{sum += $3} END {if (NR>0) print int(sum/NR)}' pings.log)
HIGH_COUNT=$(awk '$3 > 100 {count++} END {print count+0}' pings.log)

sed -i "s/^q1_avg_latency:.*/q1_avg_latency: ${AVG_LAT}/" answers.txt
sed -i "s/^q2_high_latency_count:.*/q2_high_latency_count: ${HIGH_COUNT}/" answers.txt

# 2. Plan bandwidth aggregation using associative array
awk -F, 'NR>1 {plan[$3] += $4} END {for (p in plan) print p "\t" plan[p]}' usage.csv | sort > revenue.txt

# 3. Unique slow hosts (>100ms)
awk '$3 > 100 {print $2}' pings.log | sort -u > slow.txt

# 4. solution.sh
cat > solution.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
INPUT="${1:-}"
if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
    exit 0
fi
awk 'NF>=3 {sum += $3; count++} END {if (count > 0) print int(sum/count)}' "$INPUT"
EOF
chmod +x solution.sh
