# 🎫 Ticket 12 — The Latency Ledger
> **From:** Prakash · **Priority:** P2 · **Queue:** Tier 3 — Text Processing

Prakash from the NOC is monitoring regional uplink latencies and customer bandwidth utilization. He has a stream of network probes in `pings.log` and the latest billing export `usage.csv`.

He needs key performance metrics computed: the overall network average ping latency, an inventory of persistently slow network switches, and a plan-by-plan bandwidth aggregation report for finance.

## Your tasks
In `~/dojo/12-awk/`:
1. Fill in `answers.txt` using metrics extracted from `pings.log` (`timestamp host latency_ms`):
   - `q1_avg_latency`: The overall average latency across all ping records in `pings.log`, formatted as an integer (floor or rounded value).
   - `q2_high_latency_count`: Count of ping records with latency **strictly greater** than 100 ms (`latency_ms > 100`).
2. Generate `revenue.txt` from `usage.csv` (`customer_id,name,plan,gb_used`) by summing total `gb_used` grouped by `plan` using an `awk` associative array.
   - Format: `plan<TAB>total_gb` per line.
   - Sorted alphabetically by plan name.
3. Extract all unique hostnames (field 2) from `pings.log` that recorded latency strictly greater than 100 ms. Save them sorted alphabetically to `slow.txt`.
4. Create an executable script `solution.sh` (`chmod +x solution.sh`) that accepts any ping log file as `$1` (`./solution.sh input.log`) and prints the integer average latency across all rows.

## Success criteria
Run `dojo check 12`. All rubric checks pass.

## Stuck?
`dojo hint 12` — three progressive hints.

## 💼 Interview angle
`awk` is the standard tool for one-line aggregation, field arithmetic, and grouping in Linux systems administration. Interviewers frequently ask for grouped totals (e.g. status code counts or bytes per user) where pure bash loops are clumsy and slow.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/12-awk

# 1. Calculate average latency and count of >100ms pings
AVG_LAT=$(awk '{sum += $3} END {print int(sum/NR)}' pings.log)
HIGH_COUNT=$(awk '$3 > 100 {count++} END {print count+0}' pings.log)

sed -i "s/^q1_avg_latency:.*/q1_avg_latency: ${AVG_LAT}/" answers.txt
sed -i "s/^q2_high_latency_count:.*/q2_high_latency_count: ${HIGH_COUNT}/" answers.txt

# 2. Plan bandwidth aggregation using associative array
awk -F, 'NR>1 {plan[$3] += $4} END {for (p in plan) print p "\t" plan[p]}' usage.csv | sort > revenue.txt

# 3. Unique slow hosts (>100ms)
awk '$3 > 100 {print $2}' pings.log | sort -u > slow.txt

# 4. General solution script
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

# 5. Verify
dojo check 12
```
</details>
