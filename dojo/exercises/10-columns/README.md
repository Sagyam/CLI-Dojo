# 🎫 Ticket 10 — Top Talkers
> **From:** Anita · **Priority:** P2 · **Queue:** Tier 3 — Text Processing

Anita is preparing for the quarterly ISP pricing and bandwidth allocation meeting. She pulled a raw usage export `usage.csv` containing customer bandwidth data, but she needs a clean breakdown of available service plans, a league table of the top 5 heaviest bandwidth consumers ("top talkers"), and some quick totals before the meeting starts.

## Your tasks
In `~/dojo/10-columns/`:
1. Extract all unique plan names from `usage.csv` (column 3: `plan`), sort them alphabetically, and save them to `plans.txt`.
2. Extract the top 5 customers by bandwidth usage (`gb_used`, column 4). Save the output to `top5.txt` in descending order of usage. Each line must be tab-separated: `<customer_id>\t<gb_used>`.
3. Fill in `answers.txt` with:
   - `q1_unique_customers`: Count of unique customer IDs in `usage.csv`.
   - `q2_total_rows`: Total number of data rows in `usage.csv` (excluding the header).
4. Create an executable script `solution.sh` (`chmod +x solution.sh`) that accepts a path to any same-format CSV file as `$1` and outputs the top 5 customers formatted as `<customer_id>\t<gb_used>` sorted descending by usage.

## Success criteria
Run `dojo check 10`. All rubric checks pass.

## Stuck?
`dojo hint 10` — three progressive hints.

## 💼 Interview angle
Tabular data manipulation with `cut`, `sort`, `uniq`, and `awk` is the backbone of quick log and metric analysis in production incidents. Interviewers routinely test whether you know `-t`, `-k`, and `-n` flags in `sort` without reaching for a Python script.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/10-columns

# 1. Unique sorted plan names (skip header)
tail -n +2 usage.csv | cut -d, -f3 | sort -u > plans.txt

# 2. Top 5 customers by GB (descending, tab-separated)
tail -n +2 usage.csv | sort -t, -k4,4nr | head -n 5 | awk -F, '{print $1 "\t" $4}' > top5.txt

# 3. Answer sheet calculations
UNIQUE_CUST=$(tail -n +2 usage.csv | cut -d, -f1 | sort -u | wc -l)
TOTAL_ROWS=$(tail -n +2 usage.csv | wc -l)

sed -i "s/^q1_unique_customers:.*/q1_unique_customers: ${UNIQUE_CUST}/" answers.txt
sed -i "s/^q2_total_rows:.*/q2_total_rows: ${TOTAL_ROWS}/" answers.txt

# 4. General solution script
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

# 5. Verify
dojo check 10
```
</details>
