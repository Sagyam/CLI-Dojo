# 🎫 Ticket 16 — The Missing Deploy Tool
> **From:** Prakash · **Priority:** P2 · **Queue:** Tier 4 — DevOps Flavor

Prakash was trying to run `yetideploy` to trigger the nightly staging rollout, but the terminal threw `command not found: yetideploy`. The binary exists on the system inside `~/dojo/16-env-path/tools/`, but it is not in the system executable search path (`$PATH`).

Furthermore, `yetideploy` requires two environment variables to authenticate and target the deployment:
- `YETI_ENV`: The environment name specified in the setup notice below.
- `YETI_REGION`: Must be `ap-south-1`.

These environment variables must be persistent so that any new interactive or login shell automatically loads them from `~/.zshrc`.

## Environment requirements for your ticket
Check `DEPLOY_ENV.txt` in your workdir for your assigned `YETI_ENV` value (e.g. `staging-pokhara`).

## Your tasks
In `~/dojo/16-env-path/`:
1. Make `yetideploy` executable and resolvable by name from any directory in a login shell. You can place a symlink/copy in `~/bin/` or add `~/dojo/16-env-path/tools` to your `$PATH` in `~/.zshrc`.
2. Persistently export the required environment variables in `~/.zshrc`:
   - `export YETI_ENV=<assigned_value>`
   - `export YETI_REGION=ap-south-1`
3. Execute `yetideploy` and redirect its output token to `token.txt`.
4. Record the first directory entry in your login shell `$PATH` in `answers.txt` (`q1_first_path_dir`).

## Success criteria
Run `dojo check 16`. All rubric checks pass:
- `~/.zshrc` loads cleanly without errors.
- `yetideploy` is resolvable via `command -v yetideploy` in a new shell.
- `YETI_ENV` and `YETI_REGION` are exported with the required values in login shells.
- `token.txt` contains the valid deployment token produced by `yetideploy`.
- `answers.txt` contains the first directory listed in your `$PATH`.

## Stuck?
`dojo hint 16` — three progressive hints.

## 💼 Interview angle
Understanding the distinction between shell variables and exported environment variables, `$PATH` resolution order, and shell startup files (`~/.zshrc`, `~/.bashrc`, `/etc/profile`) is one of the most common Linux debugging scenarios. In real environments, broken PATH or missing exports in non-interactive CI/CD runners cause frequent build failures.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/16-env-path

# 1. Inspect required environment value
ASSIGNED_ENV=$(cat DEPLOY_ENV.txt)

# 2. Make tool executable and symlink to ~/bin (which is in default PATH)
chmod +x tools/yetideploy
mkdir -p ~/bin
ln -sf "$HOME/dojo/16-env-path/tools/yetideploy" "$HOME/bin/yetideploy"

# 3. Add durable exports to ~/.zshrc if not already present
if ! grep -q "YETI_ENV=" ~/.zshrc; then
    echo "export YETI_ENV=${ASSIGNED_ENV}" >> ~/.zshrc
    echo "export YETI_REGION=ap-south-1" >> ~/.zshrc
fi

# 4. Source or export in current subshell and run yetideploy
export YETI_ENV="${ASSIGNED_ENV}"
export YETI_REGION="ap-south-1"
yetideploy > token.txt

# 5. Record first directory in PATH into answers.txt
FIRST_PATH=$(echo "$PATH" | cut -d: -f1)
sed -i "s|^q1_first_path_dir:.*|q1_first_path_dir: ${FIRST_PATH}|" answers.txt

# 6. Verify
dojo check 16
```
</details>
