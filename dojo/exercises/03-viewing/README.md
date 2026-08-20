# 🎫 Ticket 03 — The 400 MB Router Log
> **From:** Prakash · **Priority:** P1 · **Queue:** Tier 1 — Survival

Prakash from the NOC is frantically waving across the room: "The core router threw an unhandled exception and dropped our uplink to Pokhara! The raw dump is in `~/dojo/03-viewing/core-router.log`. Whatever you do, do NOT open the whole file in vim or nano or you will lock up the machine — use streaming inspection tools!"

## Your tasks
In `~/dojo/03-viewing/`:
1. Save the **first 5 lines** of `core-router.log` into `first5.txt`.
2. Save the **last 5 lines** of `core-router.log` into `last5.txt`.
3. Count the total lines in `core-router.log` (via `wc -l`) and record it in `answers.txt` under `q1_total_lines:`.
4. Locate the single line containing `PANIC` and save that exact line to `panic.txt`.
5. Find the **line number** where the `PANIC` occurred (1-indexed) and record it in `answers.txt` under `q2_panic_line_number:`.

## Success criteria
Run `dojo check 03`. All 5 rubric tests pass.

## Stuck?
`dojo hint 03` — three progressive hints.

## 💼 Interview angle
During high-severity production outages, viewing huge multi-gigabyte log dumps using `head`, `tail`, `grep -n`, `less`, or `sed` without loading the full file into memory is a mandatory competency tested in almost every SRE interview.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/03-viewing

# 1. First and last 5 lines
head -n 5 core-router.log > first5.txt
tail -n 5 core-router.log > last5.txt

# 2. Total lines
TOTAL=$(wc -l < core-router.log | tr -d ' ')
sed -i "s/^q1_total_lines:.*/q1_total_lines: ${TOTAL}/" answers.txt

# 3. Locate PANIC line and line number
grep "PANIC" core-router.log > panic.txt
PANIC_NUM=$(grep -n "PANIC" core-router.log | cut -d: -f1)
sed -i "s/^q2_panic_line_number:.*/q2_panic_line_number: ${PANIC_NUM}/" answers.txt

# 4. Check
dojo check 03
```
</details>
