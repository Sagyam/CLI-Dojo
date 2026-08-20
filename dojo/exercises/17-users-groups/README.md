# 🎫 Ticket 17 — The Account Audit
> **From:** Suresh dai · **Priority:** P2 · **Queue:** Tier 4 — DevOps Flavor

Security sent an audit questionnaire regarding system accounts, privileged users, and login shell assignments. You have read-only audit duties: inspect `/etc/passwd` and `/etc/group`, answer the compliance questions, and perform an onboarding verification by logging in as our new junior admin, Tara.

## Your tasks
In `~/dojo/17-users-groups/`:
1. Check `TARGET_USER.txt` to find the target username to audit (e.g. `suresh_ops`), and record that user's numeric **UID** in `answers.txt` (`q1_target_user_uid`).
2. Count how many total accounts in `/etc/passwd` have a **real login shell** (defined as any shell that does *not* end in `nologin`, `false`, or `sync`), and record the count in `answers.txt` (`q2_real_shell_count`).
3. Identify which non-root user account belongs to the `sudo` group and record the username in `answers.txt` (`q3_sudo_user`).
4. Look up the **GID** of the `billing` group from `/etc/group` and record it in `answers.txt` (`q4_billing_gid`).
5. Record the 1-based field number in `/etc/passwd` (colon-delimited) that stores the user's login shell in `answers.txt` (`q5_passwd_shell_field_number`).
6. Review Tara's temporary password in `HR_NOTE.txt`, switch to her account using `su - tara`, and create `/home/tara/proof.txt` containing the output of the `id` command. The file must be owned by `tara`.

## Success criteria
Run `dojo check 17`. All rubric checks pass:
- `answers.txt` contains accurate values for UID, real shell count, sudo member, billing GID, and shell field number.
- `/home/tara/proof.txt` exists, is owned by `tara`, and contains valid `id` output for user `tara`.

## Stuck?
`dojo hint 17` — three progressive hints.

## 💼 Interview angle
User and group administration, permission models, `/etc/passwd` anatomy, and `sudo` access governance are standard interview topics. Questions like "how do you disable login for a service account?" (`/usr/sbin/nologin`), "what is field 7 of `/etc/passwd`?" (login shell), and "how do you list group members?" (`getent group`) test fundamental Linux security awareness.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/17-users-groups

# 1. Target user UID
TARGET=$(cat TARGET_USER.txt)
TARGET_UID=$(id -u "$TARGET")
sed -i "s/^q1_target_user_uid:.*/q1_target_user_uid: ${TARGET_UID}/" answers.txt

# 2. Count real login shells (exclude nologin, false, sync)
REAL_SHELLS=$(grep -vE '(nologin|false|sync)$' /etc/passwd | wc -l)
sed -i "s/^q2_real_shell_count:.*/q2_real_shell_count: ${REAL_SHELLS}/" answers.txt

# 3. Non-root user in sudo group
SUDO_USER=$(getent group sudo | cut -d: -f4 | tr ',' '\n' | grep -v '^root$' | head -n 1)
sed -i "s/^q3_sudo_user:.*/q3_sudo_user: ${SUDO_USER}/" answers.txt

# 4. Billing GID
BILLING_GID=$(getent group billing | cut -d: -f3)
sed -i "s/^q4_billing_gid:.*/q4_billing_gid: ${BILLING_GID}/" answers.txt

# 5. Passwd shell field number is 7
sed -i "s/^q5_passwd_shell_field_number:.*/q5_passwd_shell_field_number: 7/" answers.txt

# 6. Switch to tara and generate proof.txt
TARA_PASS=$(grep -oE 'Password: [^ ]+' HR_NOTE.txt | awk '{print $2}')
echo "$TARA_PASS" | su - tara -c "id > ~/proof.txt"

# 7. Verify
dojo check 17
```
</details>
