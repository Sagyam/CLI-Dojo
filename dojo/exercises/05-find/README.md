# 🎫 Ticket 05 — Disk Janitor
> **From:** Suresh dai · **Priority:** P1 · **Queue:** Tier 2 — Interview Core

The primary storage volume on `yetilink-ops-01` is at 91% capacity. Suresh dai walks over: "Find the garbage. Do not blindly `rm -rf` anything. Touch nothing you can't justify with an explicit rule."

## Your tasks
In `~/dojo/05-find/`:
1. Delete only `*.tmp` files under `storage/` that were modified **more than 7 days ago** (`-mtime +7`). Recent `.tmp` files must not be deleted!
2. Write the count of deleted old `.tmp` files into `answers.txt` under `q1_deleted_old_tmp_count:`.
3. Find all regular files under `storage/` that are **strictly larger than 10 Megabytes** (`-size +10M`) and write their paths into `big-files.txt`, sorted with `LC_ALL=C sort`.
4. Find all regular files under `storage/` that are **world-writable** (`-perm -002` or `o=w`) and write their paths into `insecure.txt`, sorted with `LC_ALL=C sort`.
5. Find and remove all **empty directories** under `storage/` (`-type d -empty`).

## Success criteria
Run `dojo check 05`. All 6 rubric items pass.

## Stuck?
`dojo hint 05` — three progressive hints.

## 💼 Interview angle
`find` with filters on `-mtime`, `-size`, `-perm`, and action switches (`-delete` vs `-exec … {} +` vs `xargs`) is a staple DevOps technical screening question for filesystem maintenance and security auditing.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/05-find

# 1. Count and delete old tmp files
OLD_COUNT=$(find storage -type f -name "*.tmp" -mtime +7 | wc -l)
sed -i "s/^q1_deleted_old_tmp_count:.*/q1_deleted_old_tmp_count: ${OLD_COUNT}/" answers.txt
find storage -type f -name "*.tmp" -mtime +7 -delete

# 2. Big files >10MB
find storage -type f -size +10M | LC_ALL=C sort > big-files.txt

# 3. Insecure world-writable files
find storage -type f -perm -002 | LC_ALL=C sort > insecure.txt

# 4. Remove empty directories
find storage -depth -type d -empty -delete

# 5. Check work
dojo check 05
```
</details>
