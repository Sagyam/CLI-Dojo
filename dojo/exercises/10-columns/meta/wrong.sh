#!/usr/bin/env bash
# Flawed attempt: sorts alphabetically instead of numerically, missing -n
set -euo pipefail

WORK="${WORK:-/home/student/dojo/10-columns}"
cd "$WORK"

# Flaw 1: Includes header in plans.txt
cut -d, -f3 usage.csv | sort -u > plans.txt

# Flaw 2: Alphabetical sort instead of numeric (e.g. "99" > "1000")
sort -t, -k4,4r usage.csv | grep -v '^customer_id' | head -n 5 | awk -F, '{print $1 "\t" $4}' > top5.txt

sed -i "s/^q1_unique_customers:.*/q1_unique_customers: 999/" answers.txt
sed -i "s/^q2_total_rows:.*/q2_total_rows: 999/" answers.txt

cat > solution.sh << 'EOF'
#!/usr/bin/env bash
sort -t, -k4,4r "$1" | head -n 5 | awk -F, '{print $1 "\t" $4}'
EOF
chmod +x solution.sh
