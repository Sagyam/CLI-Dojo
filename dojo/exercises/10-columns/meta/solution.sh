#!/usr/bin/env bash
# Reference solution for 10-columns
set -euo pipefail

WORK="${WORK:-/home/student/dojo/10-columns}"
cd "$WORK"

# 1. Unique sorted plan names
tail -n +2 usage.csv | cut -d, -f3 | sort -u > plans.txt

# 2. Top 5 customers by GB (descending, tab-separated)
tail -n +2 usage.csv | sort -t, -k4,4nr | head -n 5 | awk -F, '{print $1 "\t" $4}' > top5.txt

# 3. Answers sheet
UNIQUE_CUST=$(tail -n +2 usage.csv | cut -d, -f1 | sort -u | wc -l)
TOTAL_ROWS=$(tail -n +2 usage.csv | wc -l)

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
tail -n +2 "$INPUT" | sort -t, -k4,4nr | head -n 5 | awk -F, 'NF>=4 {print $1 "\t" $4}'
EOF
chmod +x solution.sh
