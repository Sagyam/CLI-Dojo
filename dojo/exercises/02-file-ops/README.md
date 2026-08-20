# 🎫 Ticket 02 — The Great Shared-Drive Cleanup
> **From:** Anita · **Priority:** P2 · **Queue:** Tier 1 — Survival

Anita from Billing stopped by: "The contracts folder is a disaster. There are files from three different years dumped together, junk temporary files everywhere, and Kathmandu ISP's contract was saved with a typo. Also, we need to restructure our production configuration links before the audit!"

## Your tasks
In `~/dojo/02-file-ops/`:
1. Create a structured directory tree: `contracts/2023/`, `contracts/2024/`, and `contracts/2025/`.
2. Move all `.pdf` contract files from `raw_contracts/` into their matching year folder.
3. Rename the misspelled file `client_katmandu_2024.pdf` to `client_kathmandu_2024.pdf` inside `contracts/2024/`.
4. Delete all junk files (`*.tmp`, `.DS_Store`, `*.bak`) and remove the empty `raw_contracts/` folder.
5. Create a **symbolic link** named `config-current.yaml` in the workdir pointing to `config-2025.yaml`.
6. Create a **hard link** named `config-backup.yaml` in the workdir pointing to `config-2025.yaml`.
7. Delete the original file `config-2025.yaml` (`rm config-2025.yaml`).
8. In `answers.txt`, answer:
   - `q1_surviving_link_type`: Which link (`config-current.yaml` or `config-backup.yaml`) still contains the contract configuration data after deleting the target?
   - `q2_survivor_link_count`: What is the link count of the surviving file (via `stat -c %h config-backup.yaml`)?

## Success criteria
Run `dojo check 02`. All 7 rubric tests pass.

## Stuck?
`dojo hint 02` — three progressive hints.

## 💼 Interview angle
Understanding the fundamental difference between hard links (pointers to an inode on the filesystem) and soft/symbolic links (pointers to a path string) is one of the top 5 most frequently asked Linux interview questions.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/02-file-ops

# 1. Create directory structure
mkdir -p contracts/2023 contracts/2024 contracts/2025

# 2. Move files by year
mv raw_contracts/*2023.pdf contracts/2023/
mv raw_contracts/*2024.pdf contracts/2024/
mv raw_contracts/*2025.pdf contracts/2025/

# 3. Rename misspelled contract
mv contracts/2024/client_katmandu_2024.pdf contracts/2024/client_kathmandu_2024.pdf

# 4. Clean up junk and raw folder
rm -rf raw_contracts

# 5. Create links
ln -s config-2025.yaml config-current.yaml
ln config-2025.yaml config-backup.yaml

# 6. Delete target
rm config-2025.yaml

# 7. Fill answers
sed -i 's/^q1_surviving_link_type:.*/q1_surviving_link_type: config-backup.yaml/' answers.txt
sed -i 's/^q2_survivor_link_count:.*/q2_survivor_link_count: 1/' answers.txt

# 8. Check work
dojo check 02
```
</details>
