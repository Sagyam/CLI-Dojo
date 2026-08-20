#!/usr/bin/env bash
# Flawed attempt: uses >= 100 instead of > 100, and forgets to skip CSV header
set -euo pipefail

WORK="${WORK:-/home/student/dojo/12-awk}"
cd "$WORK"

# Flaw 1: >= 100 miscounts boundary 100ms rows
HIGH_COUNT=$(awk '$3 >= 100 {count++} END {print count+0}' pings.log)

sed -i "s/^q1_avg_latency:.*/q1_avg_latency: 9999/" answers.txt
sed -i "s/^q2_high_latency_count:.*/q2_high_latency_count: ${HIGH_COUNT}/" answers.txt

# Flaw 2: Aggregates header 'plan' and 'gb_used'
awk -F, '{plan[$3] += $4} END {for (p in plan) print p "\t" plan[p]}' usage.csv | sort > revenue.txt

# Flaw 3: >= 100
awk '$3 >= 100 {print $2}' pings.log | sort -u > slow.txt

cat > solution.sh << 'EOF'
#!/usr/bin/env bash
echo "0"
EOF
chmod +x solution.sh
