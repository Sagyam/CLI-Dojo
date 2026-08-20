# 🎫 Ticket 04 — RTFM, Respectfully
> **From:** Suresh dai · **Priority:** P2 · **Queue:** Tier 1 — Survival

Every time you ask Suresh dai how a command works, he grunts: "man page. Section number. Go." Learning to query system documentation and inspect builtins vs binaries is the superpower that separates junior admins who memorize flags from seniors who can figure out anything on a disconnected server.

## Your tasks
In `~/dojo/04-help/answers.txt`, answer the following questions:
1. `q1_crontab_format_section`: Which man **section number** documents the crontab configuration **file format**? (Check `man -k crontab` or `apropos crontab`).
2. `q2_cd_type`: Is `cd` a **builtin** or a standalone binary executable? (Inspect with `type cd`).
3. `q3_awk_binary_path`: What is the full filesystem path to the `awk` binary? (Check `which awk` or `command -v awk`).
4. `q4_typescript_cmd`: Use `apropos` to search for the tool described as "make typescript of terminal session". What is the command name?
5. `q5_sysadmin_man_section`: Which standard manual **section number** is dedicated to System Administration and daemon commands?

## Success criteria
Run `dojo check 04`. All 5 rubric tests pass.

## Stuck?
`dojo hint 04` — three progressive hints.

## 💼 Interview angle
Understanding standard man sections (1: User commands, 5: File formats, 8: System admin) and why shell builtins (`cd`, `export`, `alias`) don't have standalone binary paths in `/bin` are foundational interview questions.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/04-help

# 1. crontab file format section is 5 (crontab(5))
# 2. cd is a shell builtin
# 3. awk path is /usr/bin/awk
# 4. typescript tool is script
# 5. sysadmin commands are section 8 (e.g. mount(8), iptables(8))

cat > answers.txt << 'EOF'
# YetiLink ticket 04 — answer sheet. Fill values after each colon.
q1_crontab_format_section: 5
q2_cd_type: builtin
q3_awk_binary_path: /usr/bin/awk
q4_typescript_cmd: script
q5_sysadmin_man_section: 8
EOF

dojo check 04
```
</details>
