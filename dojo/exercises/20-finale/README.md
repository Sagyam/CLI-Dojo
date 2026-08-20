# 🎫 Ticket 20 — The Pager Goes Off (Finale)
> **From:** Suresh dai · **Priority:** P1-CRITICAL · **Queue:** Finale — Incident Response

It is Saturday, 3:14 AM. Prakash is unreachable, the monitoring alerts are screaming, and you are the sole on-call Systems Engineer on duty. Six incident tickets have just dropped in your lap.

This is your final trial. There are no artificial timers enforced, but in a real incident or interview you would aim to clear this board in 45 minutes.

---

## The Incident Board

### 🚨 Ticket 1 — Disk Filling Fast
An active service `yeti-live-logger` is filling `incident/app.log`.
- **Task:** Recover the disk space by truncating `incident/app.log` down to 0 bytes.
- **Rule:** Do NOT kill `yeti-live-logger` and do NOT delete the file with `rm`.

### 🚨 Ticket 2 — Rogue CPU Hog
A misbehaving runaway daemon `stubbornd` is spinning.
- **Task:** Terminate `stubbornd`.
- **Rule:** Do NOT terminate the legitimate authentication daemon `yeti-authd` (it must stay running!).

### 🚨 Ticket 3 — Rogue Config Injection
One of the hundreds of server configs in `incident/configs/` contains a rogue DNS server (`198.51.100.X`).
- **Task:** Find the compromised file and save its relative path to `t3_rogue_file.txt` (e.g. `incident/configs/srv_042.conf`).
- **Task:** Record the rogue IP in `answers.txt` (`t3_rogue_val`).

### 🚨 Ticket 4 — Permissions Lockout
A recent deployment locked `incident/secure/billing.conf` with `000` permissions.
- **Task:** Restore its permissions to `640` (`rw-r-----`).

### 🚨 Ticket 5 — 3 AM Access Log Forensics
We received an access surge in `incident/access.log`.
- **Task:** Extract the **top 3 client IP addresses** sorted descending by request count, formatted as `<count>\t<ip>`, into `t5_top3_ips.txt`.
- **Task:** Count the total number of **HTTP 5xx server error responses** (status codes 500–599) and record the count in `answers.txt` (`t5_total_5xx`).

### 🚨 Ticket 6 — Evidence Bundle
Suresh dai needs all evidence packaged for the post-mortem.
- **Task:** Bundle `t3_rogue_file.txt`, `t5_top3_ips.txt`, and `answers.txt` into a compressed archive named `evidence.tar.gz` in the root of `~/dojo/20-finale/`.
- **Rule:** Paths inside the archive must be relative (no leading `/` or extra path prefixes).

---

## Success criteria
Run `dojo check 20`. All 10 scorecard checks pass across all 6 tickets.

## Stuck?
`dojo hint 20` — progressive hints across the incident tickets.

## 💼 Interview angle
This finale directly mirrors real-world DevOps/SRE practical interviews (e.g. live debugging sessions at Stripe, Datadog, AWS). Candidates are given a broken VM/container with multiple interacting issues and evaluated on command-line speed, diagnostics accuracy, log analysis, process management, and safe operations.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/20-finale

# Ticket 1: Truncate open log
truncate -s 0 incident/app.log

# Ticket 2: Terminate stubborn process
pkill -9 -f "^stubbornd"

# Ticket 3: Find rogue config
ROGUE_FILE=$(grep -rl "198\.51\.100\." incident/configs/)
echo "$ROGUE_FILE" > t3_rogue_file.txt
ROGUE_IP=$(grep -oE '198\.51\.100\.[0-9]+' "$ROGUE_FILE" | head -n 1)
sed -i "s/^t3_rogue_val:.*/t3_rogue_val: ${ROGUE_IP}/" answers.txt

# Ticket 4: Fix permissions
chmod 640 incident/secure/billing.conf

# Ticket 5: Access log forensics
awk '{print $1}' incident/access.log | sort | uniq -c | sort -nr | head -n 3 | awk '{print $1 "\t" $2}' > t5_top3_ips.txt
TOTAL_5XX=$(awk '$9 ~ /^5[0-9]{2}$/ {count++} END {print count+0}' incident/access.log)
sed -i "s/^t5_total_5xx:.*/t5_total_5xx: ${TOTAL_5XX}/" answers.txt

# Ticket 6: Package evidence
tar -czf evidence.tar.gz t3_rogue_file.txt t5_top3_ips.txt answers.txt

# Verify
dojo check 20
```
</details>
