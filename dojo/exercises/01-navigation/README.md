# 🎫 Ticket 01 — The Scavenger Hunt
> **From:** Suresh dai · **Priority:** P2 · **Queue:** Tier 1 — Survival

Suresh dai dropped a mockup of the Linux Filesystem Hierarchy Standard (FHS) under `~/dojo/01-navigation/fake-root/`. "Documentation? The filesystem *is* the documentation. Go explore the tree, find the answers, and put them in `answers.txt`. If you can't find files, you won't survive an on-call rotation."

## Your tasks
Navigate the tree in `~/dojo/01-navigation/` and answer the questions in `answers.txt`:
1. `q1_treasure_path`: Find the deeply nested `treasure.txt` file and enter its **full absolute path**.
2. `q2_largest_var_bytes`: Find the largest file inside `fake-root/var/` (recursively) and enter its **exact size in bytes**.
3. `q3_disguised_file_type`: In `fake-root/etc/network/vpn-adapter.conf`, someone tried to hide non-config data. Use the `file` command to inspect its magic bytes and enter its true file format (e.g. `PNG`).
4. `q4_hidden_file_count`: Count how many **hidden files** (names starting with `.`) exist directly in `fake-root/opt/backup/`.
5. `q5_relative_path_choice`: Which of the following three paths is a **relative path**? Enter `a`, `b`, or `c`:
   - `a)` `/etc/nginx/nginx.conf`
   - `b)` `../backup/config.yaml`
   - `c)` `~/dojo/01-navigation`

## Success criteria
Run `dojo check 01`. All 5 rubric items pass.

## Stuck?
`dojo hint 01` — three progressive hints.

## 💼 Interview angle
Understanding absolute vs relative paths, navigating deeply nested directory structures with globbing / `ls -la`, and using `file` to inspect true file formats rather than trusting extensions are everyday Linux survival fundamentals.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

1. Find the treasure file's absolute path:
   ```bash
   find ~/dojo/01-navigation/fake-root -name "treasure.txt"
   ```
2. Find the largest file in `fake-root/var`:
   ```bash
   ls -laSh ~/dojo/01-navigation/fake-root/var/log/
   stat -c %s ~/dojo/01-navigation/fake-root/var/log/syslog.1
   ```
3. Check the disguised file's magic bytes:
   ```bash
   file ~/dojo/01-navigation/fake-root/etc/network/vpn-adapter.conf
   ```
4. Count hidden files:
   ```bash
   ls -la ~/dojo/01-navigation/fake-root/opt/backup/
   ```
5. Fill `answers.txt` and check:
   ```bash
   dojo check 01
   ```
</details>
