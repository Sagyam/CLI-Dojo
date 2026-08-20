#!/usr/bin/env bash
# Flawed attempt: treats 4xx client errors as 5xx, and misidentifies hour
set -euo pipefail

WORK="${WORK:-/home/student/dojo/13-log-capstone}"
cd "$WORK"

# Flaw 1: Sort ascending instead of descending
awk '{print $1}' access.log | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | sort | uniq -c | sort -n | head -n 5 | awk '{print $1 "\t" $2}' > top5-ips.txt

# Flaw 2: Includes 4xx errors
awk '$9 >= 400 && $9 < 600 {
    split($4, a, ":")
    hour = a[2]
    if (length(hour) == 2) errs[hour]++
} END {
    for (h in errs) print h "\t" errs[h]
}' access.log | sort > errors-by-hour.txt

sed -i "s/^q1_total_5xx:.*/q1_total_5xx: 999999/" answers.txt
sed -i "s/^q2_busiest_hour:.*/q2_busiest_hour: 99/" answers.txt
sed -i "s/^q3_oversized_requests:.*/q3_oversized_requests: 0/" answers.txt

cat > report.sh << 'EOF'
#!/usr/bin/env bash
echo "invalid"
EOF
chmod +x report.sh
