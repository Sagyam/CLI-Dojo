# 🎫 Ticket 19 — The 92% Root Partition
> **From:** Suresh dai · **Priority:** P1 · **Queue:** Tier 4 — DevOps Flavor

Monitoring alerts fired: the disk partition mounted at `/var/log` has hit 92% utilization. We need disk space recovered immediately.

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   46G  1.5G  92% /var/log
/dev/sda2       100G   40G   55G  43% /
/dev/sda3       200G   80G  110G  43% /home
tmpfs           4.0G     0  4.0G   0% /dev/shm
```

A simulated directory structure `disk-arena/` has been prepared in your workdir. You must identify which subdirectories are eating disk space, clean up the cache, and free a massive active log file `disk-arena/app.log` *without* killing the running logger daemon (`yeti-log-writer`) or deleting the file descriptor out from under it.

## Your tasks
In `~/dojo/19-disk/`:
1. Use `du` to inspect `disk-arena/` and find the 3 largest first-level subdirectories. Save their names to `top3-dirs.txt` in descending order of size (largest first, e.g. `logs`, `backups`, `cache`).
2. Remove the bloated `disk-arena/cache/` directory entirely.
3. Free the disk space held by the active log file `disk-arena/app.log` **without** deleting the file with `rm` and **without** killing the running `yeti-log-writer` process. Use `truncate -s 0` or shell zero-redirection (`: > app.log`).
4. Fill in `answers.txt`:
   - `q1_fullest_mount`: Name of the fullest mount point according to the mock `df` table above (`/var/log`).
   - `q2_rm_open_file_reason`: Answer the multiple-choice question below (`a`, `b`, or `c`).

   *Why does running `rm` on a large file currently held open by a running process fail to free disk space immediately?*
   - `a` — The Linux kernel copies deleted open files to a swap partition before freeing blocks.
   - `b` — `rm` only modifies user permissions and leaves file contents locked.
   - `c` — `rm` unlinks the directory entry, but the inode and data blocks remain allocated until all processes close their open file descriptors.

## Success criteria
Run `dojo check 19`. All rubric checks pass:
- `top3-dirs.txt` lists the 3 largest subdirectories under `disk-arena/` in descending order.
- `disk-arena/cache/` has been removed.
- `disk-arena/app.log` exists and its size has been reduced to ~0 bytes.
- `yeti-log-writer` process is still running.
- `answers.txt` correctly identifies `/var/log` and answer `c`.

## Stuck?
`dojo hint 19` — three progressive hints.

## 💼 Interview angle
"I deleted a 50 GB log file with `rm` but `df -h` still shows the disk is full — why, and how do I fix it?" is one of the classic Linux systems interview questions. Knowing about unlinked open file descriptors (`lsof +L1` / `lsof | grep deleted`) and properly truncating open files (`truncate -s 0`) is essential knowledge.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/19-disk

# 1. Top 3 largest directories in disk-arena (largest first)
du -h --max-depth=1 disk-arena | sort -hr | grep -v 'disk-arena$' | head -n 3 | awk '{print $2}' | xargs -n1 basename > top3-dirs.txt

# 2. Delete cache directory
rm -rf disk-arena/cache

# 3. Truncate giant open log file to 0 bytes without deleting
truncate -s 0 disk-arena/app.log

# 4. Answer sheet
sed -i "s|^q1_fullest_mount:.*|q1_fullest_mount: /var/log|" answers.txt
sed -i "s/^q2_rm_open_file_reason:.*/q2_rm_open_file_reason: c/" answers.txt

# 5. Verify
dojo check 19
```
</details>
