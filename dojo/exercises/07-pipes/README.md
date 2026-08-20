# 🎫 Ticket 07 — Streams, Split and Tamed
> **From:** Prakash · **Priority:** P1 · **Queue:** Tier 2 — Interview Core

A legacy backup script `noisy-backup.sh` in `~/dojo/07-pipes/` vomits interleaved standard output and standard error lines. Prakash needs them separated, captured, and silenced properly for the post-incident postmortem.

## Your tasks
In `~/dojo/07-pipes/`:
1. Run `./noisy-backup.sh` capturing stdout into `out.log` and stderr into `err.log` simultaneously (`1> out.log 2> err.log`).
2. Run `./noisy-backup.sh` merging both streams into `combined.log` in a single command (`> combined.log 2>&1` or `&> combined.log`).
3. Run `./noisy-backup.sh` silencing stderr completely (`2>/dev/null`) while sending stdout to both the terminal screen and two files `seen.log` and `archive.log` using `tee`.
4. Capture the exit status code of `./noisy-backup.sh` (`echo $?`) and record it in `answers.txt` under `q1_script_exit_code:`.
5. **Redirection Ordering Lesson**:
   - Run `./noisy-backup.sh 2>&1 > wrong.log` (observe that `wrong.log` only catches stdout, because `2>&1` copied the terminal stdout before stdout was redirected!).
   - Run `./noisy-backup.sh > right.log 2>&1` (observe that `right.log` captures both streams).
6. Create an executable script `redirect.sh` (`chmod +x redirect.sh`) that accepts any command with arguments (e.g. `"$@"`) and runs it, sending standard output to `clean.out` and standard error to `clean.err`.

## Success criteria
Run `dojo check 07`. All 8 rubric items pass.

## Stuck?
`dojo hint 07` — three progressive hints.

## 💼 Interview angle
Understanding standard file descriptors (0: stdin, 1: stdout, 2: stderr), exit codes (`$?`), and why the order of `>file 2>&1` matters is tested in almost every junior-to-mid DevOps technical interview.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/07-pipes

# 1. Separate streams
./noisy-backup.sh > out.log 2> err.log || true

# 2. Combined stream
./noisy-backup.sh > combined.log 2>&1 || true

# 3. Silence stderr and tee stdout
./noisy-backup.sh 2>/dev/null | tee seen.log archive.log || true

# 4. Exit code
./noisy-backup.sh >/dev/null 2>&1 || EC=$?
sed -i "s/^q1_script_exit_code:.*/q1_script_exit_code: ${EC}/" answers.txt

# 5. Order demonstration
./noisy-backup.sh 2>&1 > wrong.log || true
./noisy-backup.sh > right.log 2>&1 || true

# 6. redirect.sh wrapper
cat > redirect.sh << 'EOF'
#!/usr/bin/env bash
"$@" > clean.out 2> clean.err
EOF
chmod +x redirect.sh

# 7. Check work
dojo check 07
```
</details>
