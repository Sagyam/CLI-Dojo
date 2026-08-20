# 🎫 Ticket 06 — The Rogue Resolver
> **From:** Suresh dai · **Priority:** P1 · **Queue:** Tier 2 — Interview Core

Customer support is flooded with calls: users in one district are being redirected to spam popups instead of standard websites. Someone fat-fingered or maliciously edited one node config among 8,000 files in `~/dojo/06-grep/configs/` to point to a rogue DNS resolver instead of our internal `10.10.0.53`. Also, our SSH server was hammered by a brute-force attack recorded in `auth.log`.

## Your tasks
In `~/dojo/06-grep/`:
1. Search across all 8,000 config files in `configs/` to find the single file with a `nameserver` line whose IP is **not** `10.10.0.53`.
2. Write the rogue file path to `answers.txt` under `q1_rogue_file_path:`.
3. Write the rogue IP address to `answers.txt` under `q2_rogue_ip:`.
4. In `auth.log`, count the total number of lines matching `Failed password` and record it under `q3_failed_login_lines:`.
5. In `auth.log`, count how many **unique IP addresses** attempted failed logins and record under `q4_unique_failing_ips:`.
6. Extract the rogue `nameserver` line with **2 lines of context before and after** (`grep -C 2`) into `context.txt`.
7. Create an executable script `~/dojo/06-grep/solution.sh` (`chmod +x solution.sh`) that accepts a target directory as `$1` and prints the paths of all files containing a `nameserver` line whose IP is not `10.10.0.53`.

## Success criteria
Run `dojo check 06`. All 9 rubric tests (including hidden edge-case fixture suites) pass.

## Stuck?
`dojo hint 06` — three progressive hints.

## 💼 Interview angle
Searching recursively through massive codebases or configuration repositories (`grep -rnI`, `grep -v`, `grep -E`, `grep -o`) is the quintessential command-line interview benchmark test.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/06-grep

# 1. Find rogue config and IP
ROGUE_LINE=$(grep -rn "nameserver" configs/ | grep -v "10.10.0.53")
ROGUE_FILE=$(echo "$ROGUE_LINE" | cut -d: -f1)
ROGUE_IP=$(echo "$ROGUE_LINE" | awk '{print $NF}')

sed -i "s|^q1_rogue_file_path:.*|q1_rogue_file_path: ${ROGUE_FILE}|" answers.txt
sed -i "s|^q2_rogue_ip:.*|q2_rogue_ip: ${ROGUE_IP}|" answers.txt

# 2. Auth log analytics
FAILED_COUNT=$(grep -c "Failed password" auth.log)
UNIQUE_IPS=$(grep "Failed password" auth.log | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -u | wc -l)

sed -i "s|^q3_failed_login_lines:.*|q3_failed_login_lines: ${FAILED_COUNT}|" answers.txt
sed -i "s|^q4_unique_failing_ips:.*|q4_unique_failing_ips: ${UNIQUE_IPS}|" answers.txt

# 3. Context
grep -C 2 "nameserver" "$ROGUE_FILE" > context.txt

# 4. Executable solution.sh
cat > solution.sh << 'EOF'
#!/usr/bin/env bash
target="${1:-.}"
grep -rn "nameserver" "$target" 2>/dev/null | grep -v "10.10.0.53" | cut -d: -f1
EOF
chmod +x solution.sh

# 5. Check
dojo check 06
```
</details>
