#!/usr/bin/env bash
# Alternative solution using awk for 10-columns
set -euo pipefail

WORK="${WORK:-/home/student/dojo/10-columns}"
cd "$WORK"

# 1. Unique plans with awk
awk -F, 'NR>1 {print $3}' usage.csv | sort -u > plans.txt

# 2. Top 5 with sort & cut + tr
sort -t, -k4,4nr usage.csv | grep -v '^customer_id' | head -n 5 | cut -d, -f1,4 | tr ',' '\t' > top5.txt

# 3. Answers sheet
UNIQUE_CUST=$(awk -F, 'NR>1 {print $1}' usage.csv | sort -u | wc -l)
TOTAL_ROWS=$(awk 'NR>1' usage.csv | wc -l)

sed -i "s/^q1_unique_customers:.*/q1_unique_customers: ${UNIQUE_CUST}/" answers.txt
sed -i "s/^q2_total_rows:.*/q2_total_rows: ${TOTAL_ROWS}/" answers.txt

# 4. solution.sh
cat > solution.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
INPUT="${1:-}"
if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
    exit 0
fi
sort -t, -k4,4nr "$INPUT" | grep -v '^customer_id' | head -n 5 | awk -F, '{print $1 "\t" $4}'
EOF
chmod +x solution.sh
