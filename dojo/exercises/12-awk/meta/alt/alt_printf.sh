#!/usr/bin/env bash
# Alternative solution for 12-awk using explicit printf and formatted awk
set -euo pipefail

WORK="${WORK:-/home/student/dojo/12-awk}"
cd "$WORK"

# 1. Average latency with printf %.0f
AVG_LAT=$(awk '{s += $3; n++} END {printf("%.0f\n", s/n)}' pings.log)
HIGH_COUNT=$(awk 'BEGIN{c=0} $3>100{c++} END{print c}' pings.log)

sed -i "s/^q1_avg_latency:.*/q1_avg_latency: ${AVG_LAT}/" answers.txt
sed -i "s/^q2_high_latency_count:.*/q2_high_latency_count: ${HIGH_COUNT}/" answers.txt

# 2. Plan bandwidth aggregation
awk -F, 'NR>1 {sum[$3] += $4} END {for (k in sum) printf("%s\t%d\n", k, sum[k])}' usage.csv | sort > revenue.txt

# 3. Slow hosts
awk '$3 > 100 {print $2}' pings.log | sort | uniq > slow.txt

# 4. solution.sh
cat > solution.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
INPUT="${1:-}"
if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
    exit 0
fi
awk '{sum += $3; count++} END {if (count>0) printf("%d\n", sum/count)}' "$INPUT"
EOF
chmod +x solution.sh
