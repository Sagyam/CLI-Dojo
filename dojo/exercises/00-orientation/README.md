# 🎫 Ticket 00 — Welcome to YetiLink
> **From:** Suresh dai · **Priority:** P2 · **Queue:** Tier 0 — Orientation

Welcome to YetiLink Systems Operations! HR handed you your laptop, and Suresh dai (senior systems admin) looks up from his terminal with a skeptical glance. "Before I let you touch any production servers or routers, you need to prove you can navigate our ticket system and terminal environment. Don't worry, we start easy."

## Your tasks
1. Run `dojo list` to see your overall ticket queue.
2. In your workspace `~/dojo/00-orientation/`, create a file named `hello.txt` containing your current username (the output of `whoami`).
3. Find this machine's hostname using `hostname`, and write it into `answers.txt` after `q1_hostname:`.
4. Run `dojo hint 00` to intentionally reveal Hint 1 (this teaches you how the hint system works).

## Success criteria
Run `dojo check 00`. All checks green.

## Stuck?
`dojo hint 00` — three progressive hints. No shame, hints are how you learn.

## 💼 Interview angle
In every technical screen and during your first week on a new job, quickly identifying your environment context (`whoami`, `hostname`, `id`, paths) without hesitation signals Linux confidence.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

1. Write your username into `hello.txt`:
   ```bash
   whoami > ~/dojo/00-orientation/hello.txt
   ```
2. Put the hostname into `answers.txt`:
   ```bash
   sed -i "s/^q1_hostname:.*/q1_hostname: $(hostname)/" ~/dojo/00-orientation/answers.txt
   ```
3. Reveal Hint 1:
   ```bash
   dojo hint 00
   ```
4. Check your work:
   ```bash
   dojo check 00
   ```
</details>
