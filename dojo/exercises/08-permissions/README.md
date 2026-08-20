# 🎫 Ticket 08 — The Billing Drop-Box
> **From:** Anita · **Priority:** P1 · **Queue:** Tier 2 — Interview Core

Anita needs a shared folder where both Billing and Ops engineers can drop customer invoices. All new files created in the directory must automatically inherit the `billing` group, and nobody outside those teams should have any access. Meanwhile, Suresh dai wants permissions tightened across deployment scripts and salary spreadsheets.

## Your tasks
In `~/dojo/08-permissions/`:
1. Change the group of `dropbox/` to `billing` (`chgrp billing dropbox`) and configure its permissions to `2770` (setgid enabled so newly created files inherit the group, `rwx` for owner and group, no permissions for other).
2. Set permissions of `deploy.sh` to `750` (`rwxr-x---`: owner can read/write/execute, group can read/execute, others cannot access).
3. Set permissions of `secret-salaries.csv` to `400` (`r--------`: read-only for owner, inaccessible to everyone else).
4. Create directory `shared-tmp/` with mode `1777` (`rwxrwxrwt`: sticky bit enabled, so users cannot delete each other's temporary files).
5. In `answers.txt`:
   - `q1_octal_mode`: Convert the permission string shown in the comment of `answers.txt` into its 3-digit octal number (e.g. `-rwxr-x--x` → `751`).
   - `q2_umask_for_640`: What standard octal `umask` produces `640` default file permissions (e.g. `027`)?

## Success criteria
Run `dojo check 08`. All 7 rubric checks pass.

## Stuck?
`dojo hint 08` — three progressive hints.

## 💼 Interview angle
Special permission bits (`setuid 4000`, `setgid 2000`, `sticky bit 1000`), umask calculations, and reading symbolic vs octal permissions fluently are guaranteed Linux engineering interview questions.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/08-permissions

# 1. Billing dropbox with setgid 2770
chgrp billing dropbox
chmod 2770 dropbox

# 2. Deploy script 750
chmod 750 deploy.sh

# 3. Secret salaries 400
chmod 400 secret-salaries.csv

# 4. Shared tmp with sticky bit 1777
mkdir -p shared-tmp
chmod 1777 shared-tmp

# 5. Fill answers
OCTAL=$(cat .octal_answer)
sed -i "s/^q1_octal_mode:.*/q1_octal_mode: ${OCTAL}/" answers.txt
sed -i "s/^q2_umask_for_640:.*/q2_umask_for_640: 027/" answers.txt

# 6. Check work
dojo check 08
```
</details>
