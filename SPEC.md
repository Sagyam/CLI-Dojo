# CLI Dojo — Build Specification

**Project:** A self-hosted, containerized Linux CLI practice lab with automated grading, for DevOps bootcamp students.
**Audience of this document:** The AI/engineer implementing the project. Every design decision is already made; do not re-litigate them. Where this spec says MUST, it is an acceptance criterion.
**Working name:** `cli-dojo`

---

## 1. Purpose & Product Shape

Bootcamp students are weak at Linux CLI fundamentals, and it shows in job interviews. This project is a free, local clone of the "online graded lab" genre (Killercoda / KodeKloud style): a Docker container that drops the student into a pleasant shell, gives them story-driven exercises as tickets, and grades their work automatically with instant, rubric-style feedback.

**Core loop:** `dojo start 06` → read the ticket → do the work in the shell → `dojo check 06` → see ✓/✗ per requirement → fix → re-check → move on.

### Non-goals
- No web UI, no browser component. The entire experience lives in the terminal.
- No anti-cheat. Solutions ship in the repo (collapsed in the READMEs). This is a practice tool, not an assessment tool. Hidden fixtures exist for *robustness* (preventing hardcoded answers from passing), not secrecy.
- No multi-user server. One container per student on their own machine.
- No internet required at runtime. Everything needed is baked into the image at build time.
- No enforced timers anywhere (the finale *suggests* a time box, nothing enforces it).

### Guiding pedagogical principle
**Grade outcomes, never methods.** `mv` and `cp`+`rm` must both pass a "rename this file" task. Any correct pipeline passes a text-processing task. Scenarios are engineered so the target skill is the only *sane* path (8,000 files makes manual inspection absurd), but the grader only ever inspects results.

---

## 2. Repository Layout

```
cli-dojo/
├── README.md                      # student + instructor quickstart
├── CHEATSHEET.md                  # §10
├── Makefile                       # build / test / test-one targets (§8)
├── docker-compose.yml
├── Dockerfile
├── entrypoint.sh
├── config/
│   ├── zshrc                      # baked shell config (→ /etc/skel-dojo)
│   ├── starship.toml
│   ├── nvim/init.lua              # minimal, sane defaults
│   └── motd.txt                   # ASCII banner + "type: dojo list"
├── dojo/                          # installed to /opt/dojo in the image
│   ├── bin/
│   │   ├── dojo                   # student-facing CLI (§5)
│   │   ├── dojo-setup             # root-only wrapper, sudo-whitelisted
│   │   └── dojo-grade             # root-only wrapper, sudo-whitelisted
│   ├── lib/
│   │   ├── common.sh              # logging, die(), workdir helpers
│   │   └── seed.sh                # seeded PRNG helpers (§6.3)
│   └── exercises/
│       └── NN-slug/
│           ├── README.md          # ticket: story, tasks, success criteria,
│           │                      #   collapsed <details> solution (§9)
│           ├── setup.sh           # scenario generator == reset (idempotent)
│           ├── grade.bats
│           ├── hints/1.md 2.md 3.md
│           └── meta/
│               ├── solution.sh    # canonical non-interactive reference solution
│               ├── alt/           # alt-solution scripts (≥1 where methods vary)
│               └── fixtures/      # hidden test data for pattern-3 grading
├── ci/
│   └── run-exercise-ci.sh         # the meta-test harness entrypoint (§8)
└── .github/workflows/test.yml
```

---

## 3. Container & Environment Specification

### 3.1 Base image and users
- Base: `ubuntu:24.04`.
- Ubuntu 24.04 images ship a default `ubuntu` user at uid 1000. **Remove it** (`touch /var/mail/ubuntu; userdel -r ubuntu || true`) and create `student` (uid 1000, gid 1000, shell `/usr/bin/zsh`, home `/home/student`).
- Create supplementary groups `ops` and `billing`; add `student` to both (needed by exercise 08 so `chgrp` works without root).
- Hostname (set in compose): `yetilink-ops-01`.
- Locale `C.UTF-8`, timezone `UTC` (seeded log timestamps depend on this — set `TZ=UTC` in the image).

### 3.2 Privilege model
- The interactive shell runs as `student`.
- `/etc/sudoers.d/dojo` (mode 0440):
  ```
  student ALL=(root) NOPASSWD: /opt/dojo/bin/dojo-setup, /opt/dojo/bin/dojo-grade
  ```
- `dojo-setup` and `dojo-grade` accept exactly one argument, validated against `^[0-9]{2}$`, and must verify `/opt/dojo/exercises/<id>-*/` resolves to exactly one directory. Reject anything else. No other root access exists.
- `/opt/dojo` is `root:root`, world-readable **except** `exercises/*/meta/` and `/opt/dojo/state/` which are `0700 root:root`. (Solutions are public in the READMEs anyway; locking `meta/` just prevents graders being gamed casually via hidden fixtures.)
- `/opt/dojo/state/` holds per-exercise seeds (`NN.seed`, mode 0600) and is writable only by root (i.e., by `dojo-setup`).

### 3.3 Package manifest (all preinstalled at build; MUST work offline at runtime)
- **Man pages are load-bearing:** run `yes | unminimize` in the Dockerfile, then install `man-db manpages manpages-dev`. Exercise 04 fails without real man pages. Verify `man 5 crontab` works in the built image.
- Core/teaching: `coreutils` (implicit), `findutils`, `grep`, `sed`, `gawk` (explicit — teach real awk), `less`, `file`, `tree`, `psmisc` (pstree, killall), `procps`, `lsof`, `util-linux`, `bsdmainutils`
- Archives: `tar`, `gzip`, `bzip2`, `xz-utils`, `zstd`, `zip`, `unzip`, `rsync`
- Net: `curl`, `wget`, `iproute2` (ss, ip), `dnsutils` (dig), `iputils-ping`, `netcat-openbsd`, `openssh-client`
- Data: `jq`, `python3` (powers the local API server in ex. 15; no pip packages needed — stdlib only)
- Comforts: `zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf`, `bat`, `ripgrep`, `fd-find`, `htop`, `ncdu`, `neovim`, `tmux`, `git`, `sudo`, `gosu`
- From GitHub release .deb/binaries (build-time fetch): `glow` (terminal markdown renderer, used by `dojo start`/`cheat`), `starship` (prompt), `bats-core` + `bats-support` + `bats-assert` + `bats-file` (git clone into `/opt/bats/`, pinned to specific tags — record the tags in the Dockerfile).

### 3.4 Shell experience (zsh)
- **No oh-my-zsh.** It ships uncontrolled aliases. Hand-written `zshrc` with: completion system (`compinit`), history 50k + share/ignore-dups, `zsh-autosuggestions`, `zsh-syntax-highlighting` (sourced last), fzf keybindings (Ctrl-R history search), starship prompt, `EDITOR=nvim`.
- **Alias policy (hard rule):** never alias or shadow a command being taught. Forbidden: `ls`→eza, `cat`→bat, `grep`→rg, `find`→fd, `vi`→nvim aliasing tricks. Allowed shims: `alias bat='batcat'`, `alias fd='fdfind'` (Ubuntu naming quirks only). Students MUST be practicing the real flags of the real tools.
- Modern alternatives (`rg`, `fd`, `bat`, `ncdu`, `htop`) are installed and *mentioned* in READMEs as "after you pass, try the modern way" sidebars — because the grader checks outcomes, a student using `rg` still passes, and that's fine.
- First interactive login prints `config/motd.txt` (small ASCII banner, "You are the new Junior Systems Engineer at YetiLink. Type `dojo list` to see your ticket queue.").

### 3.5 Compose, volume, persistence, reset semantics
```yaml
services:
  dojo:
    build: .
    image: cli-dojo:latest
    container_name: cli-dojo
    hostname: yetilink-ops-01
    volumes:
      - dojo-home:/home/student
    stdin_open: true
    tty: true
volumes:
  dojo-home:
```
- Student entry: `docker compose run --rm dojo` (document `docker compose up -d` + `exec` as alternative for people who want a long-lived container).
- `entrypoint.sh` runs as root: if `/home/student` (the volume) is empty, populate it from `/etc/skel-dojo/` (which the Dockerfile fills with zshrc, starship.toml, nvim config); `chown -R student:student /home/student`; then `exec gosu student zsh -l`.
- **Persistence:** the volume holds dotfiles, all exercise workdirs (`~/dojo/NN-slug/`), and progress (`~/.dojo/progress.json`). Container restarts resume exactly where the student left off.
- **Reset one exercise:** `dojo reset NN` → re-runs `setup.sh` (fresh seed, wipes that workdir).
- **Reset everything:** `docker compose down -v` (nukes the volume). Document both in the README as the two blessed reset paths.
- Runtime containers get no special capabilities and need no network. Build-time is the only phase that touches the internet.

---

## 4. Narrative Universe

All 21 exercises are tickets at **YetiLink**, a scrappy fictional ISP in Kathmandu. The student is the newly hired **Junior Systems Engineer**. Tickets are written by recurring characters — Suresh dai (grumpy senior admin, allergic to GUIs), Anita (billing lead), Prakash (NOC on-call). Flavor is light and fun (chiya breaks, load-shedding jokes, momo bribes) but the *technical content is 100% serious and interview-relevant*. English throughout; Nepali words only as seasoning. Every README ends with a short **"💼 Interview angle"** note (2–3 lines) connecting the exercise to real interview questions — this is the founder's whole motivation, keep it visible.

---

## 5. The `dojo` CLI (student-facing, `/opt/dojo/bin/dojo`)

Pure bash. Subcommands:

| Command | Behavior |
|---|---|
| `dojo list` | Ticket queue grouped by tier; per exercise show `✅ done` / `🟡 started` / `—`, plus hints used. Reads `~/.dojo/progress.json`. |
| `dojo start NN` | `sudo dojo-setup NN` (generates scenario into `~/dojo/NN-slug/`, writes fresh seed), then renders the exercise README with `glow -p`. Marks status `started`. |
| `dojo check NN` | `sudo dojo-grade NN`. Prints bats pretty output (test names = rubric lines). On full pass: celebratory line + writes `passed` + timestamp to progress. On partial: lists failed test names as "next steps". Exit code mirrors pass/fail. |
| `dojo hint NN` | Reveals the next unrevealed hint (1→2→3), records count in progress. No penalty, just tracked. |
| `dojo solution NN` | Prompts `Show the full solution? [y/N]`, then renders the solution section. Records `solution_viewed: true`. |
| `dojo reset NN` | Confirm prompt, then `sudo dojo-setup NN` (idempotent regenerate, new seed). Progress status for NN reverts to `started`. |
| `dojo progress` | Summary: N/21 complete, per-tier bars, total hints used. |
| `dojo cheat [topic]` | Renders `CHEATSHEET.md` (or just the matching section) with `glow -p`. |

Rules:
- `dojo` itself never runs as root; only the two whitelisted wrappers do.
- `progress.json` is written by `dojo-grade` (root) so the file is root-owned; `dojo` reads it. (A student *can* still edit it via sudo-less tricks? No — it's root-owned in their home; they could delete it but not forge passes without reading grader internals. Good enough for a practice tool; do not over-engineer.)
- Schema: `{ "exercises": { "06": { "status": "passed", "hints": 1, "solution_viewed": false, "passed_at": "…", "attempts": 4 } } }`.

---

## 6. Grading Engine

### 6.1 Stack
`bats-core` with `bats-support`, `bats-assert`, `bats-file` loaded from `/opt/bats/`. Each exercise's `grade.bats` begins:

```bash
setup() {
  load /opt/bats/bats-support/load
  load /opt/bats/bats-assert/load
  load /opt/bats/bats-file/load
  source /opt/dojo/lib/seed.sh
  WORK="/home/student/dojo/06-grep"
  SEED=$(cat /opt/dojo/state/06.seed)
}
```

### 6.2 The three grading patterns
1. **State assertion** — inspect end state only: files/dirs/links/permissions/processes. (`assert_file_exists`, `assert_symlink_to`, `assert_file_permission`, `pgrep` checks.) Used whenever "how they got there" is irrelevant.
2. **Seeded artifact diff** — `setup.sh` generates randomized scenario data from a seed; the grader *recomputes the expected answer from the same seed* (the reference logic lives inside the grader) and compares against the student's answer/output file. Fresh data on every reset → infinite re-practice.
3. **Executable answer** — the ticket says "save your pipeline as `solution.sh`; it must work for *any* input passed as `$1`". The grader runs it against the visible workdir data **and** hidden fixtures in `meta/fixtures/` that include edge cases (ties, empty files, weird whitespace, a single-line file). This forces general solutions; hardcoded `echo` of the visible answer fails the hidden set.

### 6.3 Seeding
`lib/seed.sh` provides deterministic helpers driven by `RANDOM=$SEED`: `seeded_int MIN MAX`, `seeded_pick item…`, `seeded_ip`, `seeded_word` (from a small wordlist baked into lib). `dojo-setup` writes a fresh random seed to `/opt/dojo/state/NN.seed` (0600) each run; `setup.sh` and `grade.bats` both source `seed.sh` and consume that seed, so generator and grader always agree. **Rule: any random value the grader must verify is derived from the seed, never re-randomized.**

### 6.4 Grader style rules (MUST — these are what make "grader is never wrongly harsh" true)
- One `@test` per rubric line; the test *name* is student-facing English ("report.txt lists the 3 largest directories, biggest first").
- Never assert on exact whitespace, trailing newlines, or ordering unless the task explicitly specifies them. Normalize: `tr -s ' \t'`, strip trailing blank lines, and `LC_ALL=C sort` both sides when order is unspecified.
- Numeric comparisons compare numbers (`[ "$got" -eq "$want" ]`), not strings ("07" vs "7" must both pass).
- Wrap every student-script execution in `timeout 10` (30 for the log capstone). A hang is a test failure with a clear name, never a stuck grader.
- Graders must not depend on the student's shell state: invoke everything with explicit paths/`env -i` where it matters; never source student rc files (exception: exercise 16, which *explicitly* tests login-shell config via `zsh -ic`, documented there).
- Case-insensitive where a human would accept either, e.g. y/yes answers in answer files.
- Every grader MUST fail completely on a freshly set-up, untouched exercise (no vacuously-true tests). CI enforces this (§8).
- Filenames the student must create are stated *exactly* in the README and matched exactly by the grader — the README and grader are written as a pair; any mismatch is a bug.

---

## 7. Answer-file convention

Several exercises ask questions ("what is the uid of the suspicious account?"). Convention: `setup.sh` drops a template `answers.txt` in the workdir:

```
# YetiLink ticket NN — answer sheet. Fill values after each colon.
q1_suspicious_uid:
q2_shell_count:
```

Grader parses `key: value`, trims whitespace, compares seeded expectations. This keeps "quiz" grading uniform across exercises and trivially parseable.

---

## 8. Reliability: the Meta-Test Harness (the most important section)

The user's hard requirement: **the grader must never say "wrong" for a right answer.** The graders are therefore themselves under automated test.

### 8.1 Per-exercise CI contract (`ci/run-exercise-ci.sh NN SEED`)
Runs *inside* the built image, non-interactive, as follows:
1. `dojo-setup NN` with forced `SEED`.
2. `dojo-grade NN` → **MUST FAIL** (fresh state passes nothing; catches vacuous graders).
3. Run `meta/solution.sh` as `student` (it performs the whole exercise non-interactively).
4. `dojo-grade NN` → **MUST PASS** (grader accepts the canonical solution).
5. For each script in `meta/alt/`: re-setup with the same seed, run alt, grade → **MUST PASS** (grader accepts method-diverse correct solutions — this is what enforces "grade outcomes not methods").
6. Where meaningful, a `meta/wrong.sh` (deliberately plausible-but-incorrect attempt) → grade → **MUST FAIL** (catches over-lenient graders). Required for all pattern-2 and pattern-3 exercises; optional for simple state-assertion ones.

### 8.2 Matrix
GitHub Actions: build image once (cached), then matrix `exercise ∈ {00..20} × seed ∈ {5 fixed seeds}`. All 105 cells green = mergeable. Also: `shellcheck` on every `.sh` (pinned version, documented excludes), `bats --count` syntax-loads every `grade.bats`, and a smoke job that boots the container and runs `dojo list`.
Local equivalents: `make test` (full matrix, sequential), `make test-one N=06 [SEED=…]`.

### 8.3 Alt-solution authoring rule
Every exercise where more than one idiomatic method exists MUST ship at least one alt (e.g., file-ops: `cp`+`rm` alt for `mv`; text: an `awk`-only alt for a `sort|uniq` pipeline; sed exercise: a `perl -pe`-free but different-sed-flags alt). Authoring alts is how grader over-strictness gets caught *before* students do.

---

## 9. Exercise README template

Rendered by `glow`; also pleasant on GitHub.

```markdown
# 🎫 Ticket NN — <Title>
> **From:** Suresh dai · **Priority:** P2 · **Queue:** <Tier name>

<2–5 sentence story.>

## Your tasks
1. …  (exact target filenames in `code`)
2. …

## Success criteria
Run `dojo check NN`. All checks green.

## Stuck?
`dojo hint NN` — three progressive hints. No shame, hints are how you learn.

## 💼 Interview angle
<2–3 lines: the interview question this maps to.>

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

<narrated solution with commands and the *why*>
</details>
```

The `<details>` block is the single source for `dojo solution NN` (the CLI extracts and renders it — implement by printing everything after the `<details>` marker).

---

## 10. Cheatsheet

`CHEATSHEET.md`, sections mirroring the five tiers, each a compact table (`command` → one-line purpose → killer flags) plus a boxed **"Interview one-liners"** list per tier (e.g., *"find files >100MB modified in the last day"*, *"top 5 IPs in an access log"*, *"why didn't rm free disk space?"*). Target length ~250 lines. `dojo cheat grep` fuzzy-matches section headers.

---

## 11. Exercise Catalog (complete, authoritative)

Conventions below: **Pattern** = grading pattern(s) from §6.2. **Seeded** = what varies per reset. All workdirs live at `~/dojo/NN-slug/`. Setup always regenerates the workdir from scratch (it IS the reset).

---

### Tier 0 — Orientation

**00 · orientation — "Welcome to YetiLink"**
Story: HR gives you your laptop; Suresh dai tells you to learn the ticket system before touching prod.
Skills: the dojo loop itself; terminal basics (`whoami`, `hostname`, `date`, tab-completion, Ctrl-R).
Tasks: run `dojo list`; create `~/dojo/00-orientation/hello.txt` containing the output of `whoami`; put the hostname into `answers.txt`; reveal hint 1 on purpose (teaches the hint system).
Pattern: 1 + answer file. Seeded: nothing (only exercise with static grading).
Grader notes: assert file contents equal `student` / `yetilink-ops-01`; assert progress shows ≥1 hint used on 00.

---

### Tier 1 — Survival

**01 · navigation — "The Scavenger Hunt"**
Story: Suresh dai refuses to tell you where anything is. "The filesystem *is* the documentation."
Skills: `cd`, `pwd`, `ls -la/-lh/-lt/-lS`, absolute vs relative paths, `~`, `-`, globbing, `file`, FHS anatomy (/etc, /var/log, /usr/bin, /opt, /tmp).
Setup (seeded): builds a decoy tree under the workdir mimicking FHS (`fake-root/etc`, `…/var/log`, etc.) containing seeded-size files, one seeded "oddball" (a PNG disguised with a `.conf` extension), hidden dotfiles, and a deeply nested `treasure` file whose path is seeded.
Tasks: answer file — absolute path of the treasure; size in bytes of the largest file under `fake-root/var`; real type of the disguised file (via `file`); count of hidden files in a given dir; which of three paths is relative.
Pattern: 2. Seeded: sizes, treasure path, oddball location.
Grader notes: accept `file` type answers case-insensitively and match on substring ("PNG image" contains "png").

**02 · file-ops — "The Great Shared-Drive Cleanup"**
Story: Anita's contracts folder is chaos: duplicates, wrong names, no structure.
Skills: `mkdir -p`, `cp -r`, `mv` (move *and* rename), `rm -r` (+ a healthy fear of it), `touch`, `ln -s` vs `ln`, `readlink -f`, `stat` (link count).
Setup (seeded): messy flat dir of contract files with seeded names/years; one `config-2024.yaml` and `config-2025.yaml`.
Tasks: build `contracts/<year>/` tree and file everything correctly; rename a seeded misspelled file; delete the seeded junk files; create symlink `config-current.yaml` → the 2025 file; create hard link `config-backup.yaml` to the same; answer file: after `rm config-2025.yaml` (they actually do it), which link still yields content and what is the link count of the survivor.
Pattern: 1 + answer file. Seeded: filenames, years, junk set.
Grader notes: `assert_symlink_to`; verify hard link via matching inode numbers (`stat -c %i`); alt-solution uses `cp`+`rm` instead of `mv`.

**03 · viewing — "The 400 MB Router Log"**
Story: NOC needs eyes on `core-router.log` — do *not* open it in an editor.
Skills: `less` (search `/`, `n`, `G`, `q`), `head`, `tail`, `tail -n +K`, `wc -l`, `nl`.
Setup (seeded): generates a large log (~200k lines, fast generation via awk) with a seeded `PANIC` marker at a seeded line number and seeded totals.
Tasks: first 5 lines → `first5.txt`; last 5 → `last5.txt`; total line count into answers; the exact line containing `PANIC` → `panic.txt` (any method: `sed -n Np`, `grep`, `head|tail`); the line number of the PANIC into answers.
Pattern: 2. Seeded: line counts, panic position/text.
Grader notes: normalize trailing newlines; alt solutions: `sed -n` vs `grep -n` vs `head|tail`.

**04 · help — "RTFM, Respectfully"**
Story: Suresh dai answers every question with "man page. section number. go."
Skills: `man` + sections (1/5/8), `man -k` / `apropos`, `--help`, `type`, `which`, `command -v`, builtins vs binaries.
Setup: static questions in answers template (this exercise is mostly un-seeded by nature; seed only which of a question-pool subset appears).
Tasks (answer file): which man *section* documents the crontab **file format** (5); is `cd` a builtin or a file (via `type`); full path of the `awk` binary; use `apropos` to find the command that "make typescript of terminal session" (`script`); which section covers system administration commands (8).
Pattern: 2 (pooled questions). Grader notes: accept "builtin"/"shell builtin".

---

### Tier 2 — Interview Core

**05 · find — "Disk Janitor"**
Story: the file server is at 91%. Suresh dai: "find the garbage. touch nothing you can't justify."
Skills: `find` by `-name/-iname`, `-type`, `-size`, `-mtime`, `-perm`, `-empty`, `-maxdepth`, `-exec … {} \;` vs `… {} +` vs `| xargs`, and `-delete` (with fear).
Setup (seeded): a sprawling tree with seeded counts of: `*.tmp` files older than 7 days (mtimes set via `touch -d`), files >10MB (sparse files — instant to create), world-writable files, empty dirs, and red-herrings (recent .tmp files that must survive).
Tasks: delete only old `.tmp` files; `big-files.txt` = paths of all files >10MB, sorted; `insecure.txt` = world-writable regular files; remove all empty dirs; answers: count of deleted tmp files.
Pattern: 1 + 2. Seeded: all counts, sizes, names.
Grader notes: verify recent `.tmp` red-herrings still exist (over-deletion fails); `big-files.txt` compared after `LC_ALL=C sort` on both sides; alt: `-delete` vs `-exec rm` vs `xargs rm`.

**06 · grep — "The Rogue Resolver"**
Story: some customers get ads instead of websites. One config file among thousands has a rogue DNS server.
Skills: `grep -r/-i/-n/-c/-l/-v`, `-E` (alternation, classes), `-A/-B/-C`, quoting patterns.
Setup (seeded): ~8,000 small config files in nested dirs; exactly one contains a seeded rogue IP on a `nameserver` line; a seeded auth log with N `Failed password` lines across M unique IPs; files with a seeded `TODO(suresh)` marker.
Tasks: answers — path of the rogue file, the rogue IP, count of failed-login lines, count of *unique* failing IPs; `context.txt` = the rogue line with 2 lines of context; `solution.sh` taking a directory `$1`, printing paths of all files containing a `nameserver` line whose IP is **not** `10.10.0.53`.
Pattern: 2 + 3. Hidden fixtures for `solution.sh`: dir where the rogue file is the *first* file; dir with zero rogues (must print nothing, exit 0); dir where a file contains the string in a comment (spec says any `nameserver` line counts — keep grader consistent with the visible README wording).
Grader notes: this is the flagship "the skill is the only sane path" exercise — 8,000 files.

**07 · pipes — "Streams, Split and Tamed"**
Story: a legacy backup script vomits interleaved stdout/stderr; Prakash needs them separated for the incident report.
Skills: `>`, `>>`, `2>`, `&>`, `2>&1` **ordering**, `|`, `tee`, `/dev/null`, `xargs`, exit codes `$?`, `&&`/`||`.
Setup (seeded): installs `noisy-backup.sh` in the workdir emitting seeded stdout lines and seeded stderr lines (distinct prefixes), exiting with a seeded nonzero code.
Tasks: run it capturing stdout→`out.log`, stderr→`err.log` (separate); run again with both merged into `combined.log` **in one command**; run again silencing stderr while teeing stdout to both screen-log `seen.log` and `archive.log`; answers: its exit code; explain-by-doing task — create `wrong.log` using the classic broken order `2>&1 >file` and `right.log` with `>file 2>&1` (grader verifies wrong.log lacks stderr and right.log has it — the ordering lesson made physical).
Pattern: 1 + 2 + 3 (`redirect.sh` graded against a *hidden variant* noisy script to prove generality).
Grader notes: content checks by grepping for seeded prefixes, order-insensitive.

**08 · permissions — "The Billing Drop-Box"**
Story: billing and ops must share a folder; nobody else may read it; deletions must be author-only.
Skills: `chmod` octal + symbolic, `chown`/`chgrp` (student is in `ops` & `billing`), `umask`, execute-bit-on-dirs meaning, setgid dirs, sticky bit, reading `ls -l` fluently.
Setup (seeded): tree of files with seeded wrong modes; a `secret-salaries.csv` with seeded mode.
Tasks: `dropbox/` with group `billing`, mode `2770` (setgid + no-other); fix `deploy.sh` to `750`; make `secret-salaries.csv` owner-read-only (`400`); create `shared-tmp/` mode `1777`; answers: octal of a file shown only as `ls -l` string in README (`-rw-r-x--x` → 651-style question, seeded); what umask yields `640` files.
Pattern: 1 + 2. Seeded: initial modes, the octal-quiz string.
Grader notes: use `stat -c %a`; accept `2770` where `stat` reports `2770`; alt: symbolic-mode-only solution.

**09 · processes — "The Zombie Cron of Building B"**
Story: two mystery daemons are eating CPU. One is legit. One ignores polite requests to die.
Skills: `ps aux`, `pgrep -f`, `kill` (TERM vs KILL semantics), `killall`, jobs/`bg`/`fg`/`&`, `nohup`, reading `/proc/PID/`, `pstree`.
Setup (seeded): launches three long-running processes with seeded argv names: `yeti-metricsd` (legit — must survive), `chaosd` (dies on SIGTERM), `stubbornd` (traps/ignores SIGTERM; only SIGKILL works). PIDs recorded to state by setup.
Tasks: identify PIDs (answers); kill `chaosd` with SIGTERM only; kill `stubbornd` (they'll discover TERM fails → escalate to `-9`); leave `yeti-metricsd` running; start `sleep 600` with `nohup … &` and record its PID; answers: which signal number is uncatchable.
Pattern: 1 + 2 (liveness via `kill -0`).
Grader notes: setup must `disown` daemons properly so they survive the setup shell; CI must prove `meta/solution.sh` handles the TERM-then-KILL dance; grader tolerates the nohup sleep having exited only if >600s passed (don't punish slow humans — check PID *was* recorded and process matches `sleep` if alive).

---

### Tier 3 — Text Processing

**10 · columns — "Top Talkers"**
Story: Anita wants a bandwidth league table from the usage export before the pricing meeting.
Skills: `cut -d -f`, `sort` (`-t -k -n -r -u`), `uniq -c`, `tr`, `wc`, `paste`, pipelines as thinking.
Setup (seeded): `usage.csv` (`customer_id,name,plan,gb_used`) with seeded rows incl. duplicate customer lines and a tie in usage.
Tasks: `plans.txt` = unique plan names, sorted; `top5.txt` = top 5 customers by GB (id + gb, tab-separated, descending); answers: count of *unique* customers; total rows; `solution.sh $1` printing top-5 for any same-shaped CSV.
Pattern: 2 + 3. Hidden fixtures: tie at rank 5 boundary (accept either tie-break order — grader compares as a *set* for tied rows), empty file (must not crash), single-row file, file with header row (README states input has a header; hidden set includes header-only file).
Grader notes: this is the exercise where naive graders are wrongly harsh — the tie-handling and ordering tolerance rules of §6.4 apply hardest here; write the grader to compare (rank,gb) with set-equality among equal-gb rows.

**11 · sed — "The Datacenter Move"**
Story: everything referencing `blr1.yetilink.internal` must move to `ktm2.yetilink.internal`. There are 60 config files. You are not opening 60 files.
Skills: `sed 's///'` + `g`, `-i` with backup suffix (`-i.bak`), delete lines `/re/d`, comment-out via substitution, line ranges, `-n` + `p`.
Setup (seeded): 60 configs with seeded counts of the old hostname, seeded deprecated directive `use_flannel yes` lines, decoy near-miss hostnames (`blr1.yetilink.internal.backup`) that must **not** change.
Tasks: replace old→new hostname across all `.conf` (in place, keep `.bak` backups); delete every line containing `use_flannel`; in `nginx.conf` comment out (prefix `# `) lines containing `deprecated_module`; `preview.txt` = using `sed -n`, print only lines 10–20 of a named file.
Pattern: 2 (grader regenerates expected file contents from seed and diffs; also asserts `.bak` files exist and equal originals; asserts decoys untouched).
Grader notes: the decoy assertion is what makes this a *regex-word-boundary* lesson; README must warn "exact hostname only"; canonical solution uses `sed 's/blr1\.yetilink\.internal\b/…/g'` — but grader only checks resulting bytes, so any correct approach passes.

**12 · awk — "The Latency Ledger"**
Story: Prakash: "the CSV gods gave us columns; awk is how we pray."
Skills: `awk -F`, `$1..$NF`, `NR`/`NF`, pattern filters, arithmetic, `printf`, `END` blocks, associative-array sum (gently).
Setup (seeded): `pings.log` (`timestamp host latency_ms`) and reuse of `usage.csv` shape from ex. 10 with seeded values.
Tasks: answers — average latency (integer, floor) across all rows; count of rows with latency >100; `revenue.txt` = per-plan total GB via awk array (`plan<TAB>total`, sorted by plan); `slow.txt` = hosts (field 2) of all >100ms rows, deduped; `solution.sh $1` = average-latency script for any same-shaped log.
Pattern: 2 + 3. Hidden fixtures: latencies that make naive integer division wrong (grader accepts floor **or** round — compute both), single row, >100 boundary rows (exactly 100 must not count; README says "strictly greater").
Grader notes: numeric tolerance policy: grader computes expected with awk itself in both floor/round variants and accepts either; document this inline in the bats file.

**13 · log-capstone — "The 3 AM Access Log"** *(the interview classic)*
Story: marketing's landing page fell over at 3 AM. You have `access.log` (combined nginx format, ~300k seeded lines). Suresh dai: "answers, not vibes."
Skills: everything from 06–12 composed; no new tools.
Setup (seeded): generator produces realistic combined-format lines: seeded IP distribution (a top-5 with clear ranks), seeded 5xx burst in one hour, seeded oversized responses, some malformed junk lines (real logs have them).
Tasks: `top5-ips.txt` (`count<TAB>ip`, desc); `errors-by-hour.txt` (`hour<TAB>5xx_count` for hours with ≥1, ascending hour); answers — total 5xx count, the single busiest hour, count of requests >1MB response size; `report.sh $1` printing the top-5 block for any combined-format log.
Pattern: 2 + 3. Hidden fixtures: log with ties in top-5, log containing only malformed lines (script must not crash; prints nothing/whatever-parses), tiny log.
Grader notes: malformed lines mean the grader's own recomputation must use the *same tolerant parsing rule* stated in the README ("a request line is one matching the combined format; skip others"). Keep README wording and grader logic literally in sync — this pair is the highest-risk grader in the project; give it extra alt-solutions (pure-awk alt, grep+cut+sort alt).

---

### Tier 4 — DevOps Flavor

**14 · archives — "Restore From the Vault"**
Story: someone fat-fingered `radius.conf`. The only good copy is inside last Tuesday's backup tarball. Also: make tonight's backup properly.
Skills: `tar -c/-t/-x`, `-z/-J/--zstd`, `-C`, extracting a *single* file, `--strip-components`, `--exclude`, checksums (`sha256sum`).
Setup (seeded): a `vault/backup-<seededdate>.tar.gz` containing a seeded tree incl. the good `radius.conf`; a live tree with the corrupted one and seeded log junk.
Tasks: list archive contents → `contents.txt`; extract *only* `radius.conf` into place (correct final path, correct bytes); create `backup-today.tar.zst` of the live `etc/` **excluding** `*.log`, with paths relative to `etc/` (via `-C`); answers: sha256 of the restored file.
Pattern: 1 + 2 (grader re-lists the student's archive with `tar -tf`, asserts exclusions and path shapes; diffs restored file against the copy embedded in the vault).
Grader notes: alt: extract-to-temp-then-`cp` vs `--strip-components` direct — both pass by design.

**15 · curl-jq — "Talking to the Customer API"**
Story: the billing API is internal-only. Learn to interrogate it from the shell, because that is where you'll be during an outage.
Skills: `curl` (`-s`, `-i`, `-o`, `-X POST`, `-H`, `-d`, `-w '%{http_code}'`), `jq` (field access, filters `select`, `map`, `length`, `-r` raw output, building strings).
Setup (seeded): starts a local stdlib-Python API on `127.0.0.1:<seeded port ∈ 8800–8899>` (root-owned script, backgrounded, pidfile in state; setup kills any prior instance first — idempotency). Endpoints: `GET /customers` (seeded JSON array), `GET /customers/<id>`, `GET /health`, `POST /notes` (echoes back; requires header `X-Auth: chiya`, else 401). README tells students the port is in `~/dojo/15-curl-jq/API_PORT`.
Tasks: `health.json` = body of /health; answers — HTTP status of `POST /notes` *without* the header (401) and *with* it (201); `names.txt` = all customer names, one per line, via `jq -r`; `premium.txt` = ids of customers with `plan == "premium"` via `jq 'select…'`; answers — customer count via `jq length`.
Pattern: 1 + 2.
Grader notes: grader curls the same API to recompute truth; CI must confirm the server survives grading and that setup-twice works (idempotent kill/restart). The API server script lives in the exercise dir and is the one non-bash program in the repo — keep it stdlib-only, ~80 lines.

**16 · env-path — "The Missing Deploy Tool"**
Story: `yetideploy` "doesn't exist" on this box. It exists. The box just doesn't know where to look. Also the app needs its env config.
Skills: env vars vs shell vars, `export`, `printenv`, `$PATH` anatomy, `~/bin` convention, editing `~/.zshrc` and re-sourcing, `command -v`, precedence/shadowing.
Setup (seeded): drops executable `yetideploy` (prints a seeded token) into an out-of-PATH dir `~/dojo/16-env-path/tools/`; README asks for specific env vars with seeded values.
Tasks: make `yetideploy` resolvable from any directory in a **login shell** (blessed route: `mkdir ~/bin`, copy/symlink, ensure PATH — but *any* durable mechanism passes); `export YETI_ENV=<seeded>` and `YETI_REGION=ap-south-1` durably in `~/.zshrc`; capture `yetideploy`'s output → `token.txt`; answers: the *first* directory in your PATH.
Pattern: 1 via login-shell probing — grader runs `timeout 10 zsh -ic 'command -v yetideploy'` and `zsh -ic 'printenv YETI_ENV'` (documented exception to the "never touch student shell state" rule — here the shell state IS the subject).
Grader notes: fragility risk is the student's zshrc erroring; grader treats nonzero `zsh -ic` as a named failure ("your ~/.zshrc must load cleanly") — that's a fair, teachable failure, not a grader bug. Alts: symlink vs copy vs `export PATH` pointing at tools/ directly.

**17 · users-groups — "The Account Audit"** *(investigate, don't administer)*
Story: security asked for an account audit. Read-only: you are junior; you audit, Suresh dai executes.
Skills: reading `/etc/passwd` & `/etc/group` (fields!), `id`, `groups`, `getent`, human vs system uid ranges, login shells vs `nologin`, `su` to a test account, `sudo -l`.
Setup (seeded): creates seeded users: 2–3 human-range accounts (one with seeded uid, one with `/usr/sbin/nologin`, one in `sudo` group), a system account, and test account `tara` with a seeded password stored in a README-visible note (from "HR onboarding email").
Tasks (answer file): uid of the seeded named user; how many accounts have a real login shell; which non-root user is in `sudo` group; gid of group `billing`; `su - tara` and create `/home/tara/proof.txt` containing tara's `id` output (proves the su worked); answers: which passwd field is the shell (7).
Pattern: 1 + 2.
Grader notes: grader recomputes from `/etc/passwd` with the same definition of "real login shell" the README states (not ending in `nologin`/`false`); the `proof.txt` ownership must be tara (`stat -c %U`).

**18 · networking — "Who's Listening?"**
Story: something is squatting on a port the new service needs; also DNS "is always DNS".
Skills: `ss -tlnp`, `ip addr`/`ip route`, `ping -c`, `dig +short` / `getent hosts`, `/etc/hosts`, `curl` against local services, ports <1024 vs unprivileged.
Setup (seeded): starts two labeled listeners (`nc -l` wrappers with distinguishable argv) on seeded ports; writes seeded expected values.
Tasks (answers + state): which process name listens on seeded port A; list all listening TCP ports (sorted) → `ports.txt`; the container's eth0 IP (via `ip addr`, into answers); add hosts entry `billing.yetilink.internal → 127.0.0.1` (needs… root? **No** — /etc/hosts is root-owned; make this the one file setup pre-chmods to `student`-writable via group, and README calls that out as a lab convenience with a note that prod needs sudo); then `curl http://billing.yetilink.internal:<portA>/` → `hosts-proof.txt`; answers: why can't an unprivileged user bind port 80 (multiple-choice a/b/c in answers template).
Pattern: 1 + 2.
Grader notes: `ports.txt` compared as sorted sets; the hosts-file convenience MUST be reverted by setup on re-run (idempotent).

**19 · disk — "The 92% Root Partition"**
Story: monitoring says 92%. Find the bloat; free space *correctly* (there is a wrong way, and prod once learned it the hard way).
Skills: `df -h`, `du -sh`, `du -h --max-depth=1 | sort -h`, `find -size`, `truncate -s 0` vs `rm` on open files (the deleted-but-open classic), `ncdu` (mentioned, ungraded).
Setup (seeded): a seeded tree with 3 clearly-largest dirs (sparse files), one giant `app.log` held **open** by a running seeded writer process.
Tasks: `top3-dirs.txt` = 3 largest first-level dirs under the tree, largest first (`du`-based, names only); delete the seeded `cache/` junk; free the giant open log the *right* way (`truncate -s 0` — grader asserts file now ~0 bytes **and** writer still running **and** file not deleted); answers: from README's mock `df` output, which mount is fullest; why `rm` on the open log wouldn't free space (multiple-choice).
Pattern: 1 + 2.
Grader notes: sparse files make `du` vs `ls` sizes differ — generator must create *non-sparse* content for the dirs being ranked (small real files repeated) so `du` ranking is deterministic; keep total workdir under ~50 MB real bytes.

---

### Finale

**20 · finale — "The Pager Goes Off"** *(mock interview, suggested 45 min, nothing enforced)*
Story: Saturday, 3 AM. Prakash is unreachable. Six tickets, one box, you.
Setup (seeded): composes generators from earlier exercises into one incident: (T1) disk filling — find & truncate the open log; (T2) a `stubbornd`-style runaway to identify and kill correctly while sparing the legit daemon; (T3) one bad config among thousands (grep) — report path + rogue value; (T4) a perms lockout — fix a `000`-mode config to `640`; (T5) log forensics — top-3 IPs and total 5xx from a fresh access log; (T6) evidence — bundle the findings files into `evidence-<date>.tar.gz` with correct relative paths.
Grading: one `grade.bats` with a `# --- Ticket N ---` section per ticket; `dojo check 20` output reads like a scorecard. Pattern mix: 1 + 2. Passing = all six.
Grader notes: reuse generator functions from earlier exercises via `lib/` (extract shared generators there rather than copy-pasting); each ticket's tests must be independent (a failed T2 can't poison T5's assertions).

---

## 12. Build Order (milestones for the implementer)

1. **M1 — Skeleton that proves the loop.** Dockerfile, compose, entrypoint, comforts, `dojo` CLI, sudoers, seed lib, exercise 00 end-to-end, `ci/run-exercise-ci.sh`, Makefile, GitHub Actions running the 00 matrix. *Nothing else starts until M1's CI is green — the harness is the foundation, not an afterthought.*
2. **M2 — Tiers 1–2** (01–09) with full meta (solution, ≥1 alt where applicable, wrong.sh where required), CI matrix extended as each lands.
3. **M3 — Tiers 3–4** (10–19). Exercise 13 and 15 are the risk items; land them early in M3.
4. **M4 — Finale + cheatsheet + polish.** Shared generator extraction into `lib/`, README pass for tone consistency, MOTD, `dojo progress` niceties.

## 13. Acceptance Criteria (definition of done)

- `make build` produces the image; `docker compose run --rm dojo` lands in zsh with prompt, highlighting, autosuggestions, and MOTD; `man 5 crontab` works.
- Container runs fully offline; only build needs network.
- `make test` green: **21 exercises × 5 seeds**, each passing the §8.1 contract (fresh-fail, reference-pass, all-alts-pass, wrong-fails where present).
- `shellcheck` clean across all shell (pinned version; exclusions listed in Makefile with justification comments).
- Every exercise README follows the §9 template, includes exact target filenames, the Interview-angle box, and a working `<details>` solution consistent with `meta/solution.sh`.
- `dojo` subcommands behave exactly per §5; progress survives container restart via the volume; `docker compose down -v` verifiably resets everything.
- Grader style rules (§6.4) hold everywhere; spot-audit: exercises 10 and 13 demonstrably accept tied/reordered-equivalent outputs.
- Total image size kept reasonable (< ~1.5 GB; unminimize + manpages are the big cost and are accepted).