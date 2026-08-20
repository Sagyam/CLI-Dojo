#!/usr/bin/env bash
# Alternative solution for 13-log-capstone using pure awk
set -euo pipefail

WORK="${WORK:-/home/student/dojo/13-log-capstone}"
cd "$WORK"

# 1. Top 5 IPs
awk '
$1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ { count[$1]++ }
END {
    for (ip in count) print count[ip] "\t" ip
}
' access.log | sort -rn | head -n 5 > top5-ips.txt

# 2. 5xx errors by hour
awk '
$9 ~ /^5[0-9][0-9]$/ {
    match($4, /:([0-9]{2}):/, m)
    if (m[1] != "") errs[m[1]]++
}
END {
    for (h in errs) print h "\t" errs[h]
}
' access.log | sort -k1,1 > errors-by-hour.txt

# 3. Answers
TOTAL_5XX=$(awk '$9 ~ /^5[0-9][0-9]$/ { c++ } END { print c+0 }' access.log)
BUSIEST_HOUR=$(awk '{ match($4, /:([0-9]{2}):/, m); if (m[1] != "") h[m[1]]++ } END { max=0; best=""; for(k in h) if(h[k]>max){max=h[k]; best=k} print best }' access.log)
OVERSIZED=$(awk '$10 > 1048576 { c++ } END { print c+0 }' access.log)

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
awk '
$1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ { count[$1]++ }
END {
    for (ip in count) print count[ip] "\t" ip
}
' "$INPUT" | sort -rn | head -n 5
EOF
chmod +x report.sh
