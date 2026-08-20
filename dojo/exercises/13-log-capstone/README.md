# 🎫 Ticket 13 — The 3 AM Access Log
> **From:** Suresh dai · **Priority:** P1 · **Queue:** Tier 3 — Text Processing

At 3:15 AM last night, marketing's promo campaign went live on the homepage, and within minutes our frontend proxies began choking. Suresh dai was woken up by the alert klaxon:

*"The incident report needs hard numbers by 9 AM. Not guesses, not vibes. You have the raw proxy `access.log`. Give me the top talkers, error distributions by hour, and the blast radius."*

The proxy log `access.log` follows standard Nginx Combined Log format:
```text
$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"
```
*(Note: Real-world logs may occasionally contain truncated or malformed lines. Your pipelines should filter for valid request records).*

## Your tasks
In `~/dojo/13-log-capstone/`:
1. Extract the top 5 client IP addresses by request count. Save the result to `top5-ips.txt` formatted as `count<TAB>ip` per line, sorted descending by count.
2. Group all `5xx` server errors (HTTP status codes 500 to 599) by their two-digit hour (`00` to `23`). Save to `errors-by-hour.txt` formatted as `hour<TAB>5xx_count` for every hour with at least 1 error, sorted ascending by hour.
3. Fill in `answers.txt` with:
   - `q1_total_5xx`: Total count of all 5xx HTTP response status codes across the entire log.
   - `q2_busiest_hour`: The two-digit hour (`00` to `23`) with the highest total number of requests.
   - `q3_oversized_requests`: Count of requests with response size strictly greater than 1 MB (1,048,576 bytes).
4. Create an executable script `report.sh` (`chmod +x report.sh`) that accepts any Nginx combined access log as `$1` (`./report.sh logfile.log`) and prints the top 5 IP addresses formatted as `count<TAB>ip` (descending).

## Success criteria
Run `dojo check 13`. All rubric checks pass.

## Stuck?
`dojo hint 13` — three progressive hints.

## 💼 Interview angle
Analyzing raw access logs under pressure is the definitive systems engineer interview test. Candidates who can fluently combine `awk`, `cut`, `sort`, and `uniq -c` on multi-hundred-megabyte log files without breaking a sweat stand out instantly.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/13-log-capstone

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

# 5. Verify
dojo check 13
```
</details>
