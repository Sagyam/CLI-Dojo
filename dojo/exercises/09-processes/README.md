# 🎫 Ticket 09 — The Zombie Cron of Building B
> **From:** Suresh dai · **Priority:** P1 · **Queue:** Tier 2 — Interview Core

Two mystery daemon processes are consuming CPU cycles on the host. One is `yeti-metricsd` (which gathers network telemetry and MUST NOT be killed). The other two are `chaosd` and `stubbornd`. Suresh dai warns you: "`chaosd` will die politely when asked. But `stubbornd` ignores standard termination signals and will refuse to die unless you know how to force it."

## Your tasks
In `~/dojo/09-processes/`:
1. Use `pgrep -fl` or `ps aux` to locate the Process IDs (PIDs) of `chaosd`, `stubbornd`, and `yeti-metricsd`, and record them in `answers.txt`.
2. Terminate `chaosd` politely using standard `SIGTERM` (`kill <PID>` or `kill -15 <PID>`).
3. Terminate `stubbornd` (try `kill -15` first, observe that it ignores the signal, and escalate to uncatchable `SIGKILL`: `kill -9 <PID>`).
4. Ensure `yeti-metricsd` remains **running**.
5. Launch a 10-minute sleep in the background using `nohup` (`nohup sleep 600 >/dev/null 2>&1 &`) and record its PID (`$!`) in `answers.txt` under `q4_nohup_sleep_pid:`.
6. In `answers.txt`, answer `q5_uncatchable_signal`: Which standard POSIX signal number (e.g. `9`) cannot be caught, blocked, or ignored by any process?

## Success criteria
Run `dojo check 09`. All 8 rubric checks pass.

## Stuck?
`dojo hint 09` — three progressive hints.

## 💼 Interview angle
Understanding process lifecycle, signal mechanics (`SIGTERM 15` vs `SIGKILL 9` vs `SIGHUP 1`), backgrounding with `nohup` / `&` / `disown`, and viewing processes via `ps` / `pgrep` is a non-negotiable Linux operations requirement.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/09-processes

# 1. Find PIDs
P_CHAOS=$(pgrep -f "chaosd" | head -n1)
P_STUBBORN=$(pgrep -f "stubbornd" | head -n1)
P_METRICS=$(pgrep -f "yeti-metricsd" | head -n1)

sed -i "s/^q1_chaosd_pid:.*/q1_chaosd_pid: ${P_CHAOS}/" answers.txt
sed -i "s/^q2_stubbornd_pid:.*/q2_stubbornd_pid: ${P_STUBBORN}/" answers.txt
sed -i "s/^q3_metricsd_pid:.*/q3_metricsd_pid: ${P_METRICS}/" answers.txt

# 2. Kill chaosd with SIGTERM (15)
kill -15 "$P_CHAOS"

# 3. Kill stubbornd with SIGKILL (9)
kill -9 "$P_STUBBORN"

# 4. Launch nohup sleep 600
nohup sleep 600 >/dev/null 2>&1 &
P_SLEEP=$!
sed -i "s/^q4_nohup_sleep_pid:.*/q4_nohup_sleep_pid: ${P_SLEEP}/" answers.txt
sed -i "s/^q5_uncatchable_signal:.*/q5_uncatchable_signal: 9/" answers.txt

# 5. Check work
dojo check 09
```
</details>
