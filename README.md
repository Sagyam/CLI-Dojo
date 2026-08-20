# 🥋 CLI Dojo

> **A self-hosted, containerized Linux CLI practice lab with automated rubric grading for DevOps engineers and bootcamp students.**

[![CI Matrix Tests](https://github.com/Sagyam/CLI-Dojo/actions/workflows/test.yml/badge.svg)](https://github.com/Sagyam/CLI-Dojo/actions/workflows/test.yml)
[![Docker Ready](https://img.shields.io/badge/docker-ready-blue.svg)](Dockerfile)
[![Ubuntu 24.04 LTS](https://img.shields.io/badge/ubuntu-24.04_LTS-orange.svg)](Dockerfile)
[![Exercises](https://img.shields.io/badge/exercises-21_ready-brightgreen.svg)](#-curriculum--exercise-catalog)
[![Grading](https://img.shields.io/badge/grading-BATS_automated-success.svg)](dojo/exercises)
[![Offline](https://img.shields.io/badge/runtime-100%25_offline-purple.svg)](#-key-features)

---

## 📖 Welcome to YetiLink

You've just been hired as the newest **Junior Systems Engineer** at **YetiLink**, a scrappy internet service provider in Kathmandu. 

Your mentor, **Suresh dai** (a senior sysadmin who is allergic to GUIs and lives on chiya breaks), along with **Anita** from Billing and **Prakash** from the NOC, will assign you real-world troubleshooting tickets. From unmasking rogue DNS resolvers and tracking down memory-eating zombie crons to parsing high-traffic 3 AM web logs and responding to 2 AM pager outages, you will build muscle memory on the real Linux command line.

```
                  ┌─────────────────────────────────────┐
                  │          YETILINK NOC OPS           │
                  │   Kathmandu Core Routing Center     │
                  └──────────────────┬──────────────────┘
                                     │
           ┌─────────────────────────┼─────────────────────────┐
           ▼                         ▼                         ▼
   [ 00-04: Fundamentals ]   [ 05-09: Search & Pipes ]   [ 10-13: Text & Logs ]
   Terminal survival,         find, grep, xargs,          cut, awk, sed,
   navigation & file ops      chmod/chown, processes      log stream parsing
           │                         │                         │
           └─────────────────────────┼─────────────────────────┘
                                     │
           ┌─────────────────────────┴─────────────────────────┐
           ▼                                                   ▼
   [ 14-19: DevOps & SRE ]                            [ 20: The Finale ]
   tar, curl, jq, $PATH,                              Production outage response:
   users, networking, disk forensics                  The Pager Goes Off!
```

---

## ✨ Key Features

- 💻 **100% Terminal-First:** No browser tabs, no web UI latency. You work entirely inside an interactive terminal environment.
- 🎯 **21 Story-Driven Tickets:** Progress through 5 tiers of increasing complexity, culminating in a live incident response capstone.
- 🧪 **Outcome-Based Automated Grading:** The grading engine (`bats-core`) evaluates **results, not methods**. Whether you solve a file task with `mv` or `cp` + `rm`, any correct approach passes.
- 🎲 **Seeded PRNG (Infinite Re-Practice):** Every scenario is seeded. Re-running `dojo reset` generates fresh random IPs, usernames, log entries, and paths so you can practice repeatedly without memorizing static values.
- 🔒 **Hidden Edge-Case Fixtures:** Text-processing tasks test your scripts against hidden edge cases (empty files, whitespace variations, single-line logs) to ensure robust solutions.
- 💼 **Interview-Angle Insights:** Every ticket connects directly to technical interview questions asked at top tech companies.
- ⚡ **Zero Internet at Runtime:** All packages, man pages, test suites, and mock APIs are baked directly into the Docker image.
- 🎨 **Modern Shell Comforts:** Ships with Zsh, Starship prompt, fzf history search, syntax highlighting, autosuggestions, and Neovim.

---

## 🚀 Quick Start

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/) (v2.0+)

### 1. Clone and Launch
```bash
git clone https://github.com/Sagyam/CLI-Dojo.git
cd CLI-Dojo

# Launch interactive container (auto-builds on first run)
docker compose run --rm dojo
```
*(Alternatively, use `make run`)*

### 2. The Core Loop

Once inside the container shell:

```bash
# 1. View your ticket queue
dojo list

# 2. Pick a ticket to start (e.g. 06 - grep)
dojo start 06

# 3. Work in the ticket directory
cd ~/dojo/06-grep
# ... run commands, analyze logs, build your solution ...

# 4. Check your work against automated test suite
dojo check 06

# 5. Need guidance? Request progressive hints without spoilers
dojo hint 06

# 6. Check overall progress across all tiers
dojo progress
```

---

## 🛠️ CLI Command Reference

The `dojo` CLI manages exercises, tickets, hint progression, and automated grading:

| Command | Description |
|---|---|
| `dojo list` | List all 21 tickets grouped by tier with real-time pass/started status. |
| `dojo start NN` | Set up exercise `NN`, generate randomized fixtures, and display the ticket brief. |
| `dojo check NN` | Grade exercise `NN` with rubric-level breakdown and pass/fail feedback. |
| `dojo hint NN` | Reveal the next progressive hint (up to 3 levels per ticket). |
| `dojo solution NN` | View the reference solution and breakdown (with confirmation prompt). |
| `dojo reset NN` | Wipe the work directory for ticket `NN` and regenerate with a fresh seed. |
| `dojo progress` | Display total completed exercises, tier completion bars, and hint stats. |
| `dojo cheat [topic]` | View the built-in `CHEATSHEET.md` or a specific topic section. |

---

## 📚 Curriculum & Exercise Catalog

CLI Dojo is structured into 5 progression tiers plus a capstone incident response finale:

| # | Ticket Slug | Tier | Focus Skills & Core Tools | Real-World Scenario |
|:---:|---|:---:|---|---|
| **00** | `orientation` | Tier 0 | `whoami`, `hostname`, `pwd`, `dojo` | Onboarding at YetiLink & shell verification |
| **01** | `navigation` | Tier 1 | `cd`, `pwd`, `ls -la`, symlinks, hidden files | Scavenger hunt through nested datacenter trees |
| **02** | `file-ops` | Tier 1 | `mkdir -p`, `cp`, `mv`, `rm -rf`, `ln -s` | Organizing scattered shared-drive departmental files |
| **03** | `viewing` | Tier 1 | `head`, `tail -n`, `less`, `wc -l`, `file` | Inspecting a 400 MB router crash dump without freezing |
| **04** | `help` | Tier 1 | `man`, `apropos`, `whatis`, man sections | Finding obscure tool flags using manual pages |
| **05** | `find` | Tier 2 | `find -name`, `-size`, `-mtime`, `-type`, `-exec` | Cleaning disk hogs and unindexed backup files |
| **06** | `grep` | Tier 2 | `grep -rnI`, `-E`, `-v`, regex filters | Pinning down rogue DNS resolvers in config trees |
| **07** | `pipes` | Tier 2 | `\|`, `sort`, `uniq -c`, `tee`, redirects `2>&1` | Taming multi-stream output and counting events |
| **08** | `permissions` | Tier 2 | `chmod` (numeric/symbolic), `chgrp`, setgid | Securing confidential billing drop-boxes |
| **09** | `processes` | Tier 2 | `ps aux`, `pgrep`, `pkill`, `kill -15/-9`, `nohup` | Hunting down a runaway zombie cron job |
| **10** | `columns` | Tier 3 | `cut -d`, `awk '{print $N}'`, `column -t` | Extracting bandwidth top talkers from tabular logs |
| **11** | `sed` | Tier 3 | `sed 's/old/new/g'`, regex grouping, in-place `-i` | Batch-migrating legacy IP ranges across configs |
| **12** | `awk` | Tier 3 | `awk` conditionals, totals, averages, formatting | Computing latency averages and SLA breach tallies |
| **13** | `log-capstone` | Tier 3 | `grep`, `awk`, `sort`, `uniq -c`, pipeline chaining | Forensic triage of a high-volume 3 AM web attack |
| **14** | `archives` | Tier 4 | `tar -czvf`, `tar -xzvf`, `gzip`, `xz`, `zip` | Extracting corrupted server snapshots and repackaging |
| **15** | `curl-jq` | Tier 4 | `curl -s`, HTTP headers, `jq` JSON filters/mappings | Querying local microservice APIs and transforming payloads |
| **16** | `env-path` | Tier 4 | `$PATH`, `export`, `.zshrc`, subshells vs sourcing | Diagnosing broken `$PATH` and fixing missing deploy tools |
| **17** | `users-groups` | Tier 4 | `useradd`, `usermod -aG`, `/etc/passwd`, `/etc/group` | Auditing orphaned user accounts and fixing permissions |
| **18** | `networking` | Tier 4 | `ss -tulpn`, `ip addr`, `dig`, `nc -zv` | Identifying rogue listening services and socket conflicts |
| **19** | `disk` | Tier 4 | `df -h`, `du -sh`, `ncdu`, `lsof +L1` (deleted files) | Resolving a 92% full root partition with unlinked open files |
| **20** | `finale` | Finale | **All Skills Combined** | 🚨 **The Pager Goes Off:** Live production incident triage! |

---

## 💾 Persistence & Reset Semantics

- **Persistent Progress:** Your work directories (`~/dojo/NN-slug/`), shell history, dotfiles, and progress (`~/.dojo/progress.json`) are stored in the Docker volume `dojo-home`. Exiting and restarting the container will resume right where you left off.
- **Reset a Single Exercise:**
  ```bash
  dojo reset 06
  ```
  Wipes and re-generates the specific exercise with a fresh seed.
- **Reset the Entire Lab:**
  ```bash
  docker compose down -v
  ```
  Deletes the Docker volume and starts fresh from Exercise 00.

---

## 🧪 Developer & Instructor Guide

CLI Dojo includes a comprehensive test suite to ensure grading accuracy and prevent false negatives.

### Local Development Makefile Targets

```bash
# Build the Docker image
make build

# Launch student shell
make run

# Test a single exercise against its canonical solution and alts
make test-one N=06 SEED=42

# Run full matrix test suite (all 21 exercises × 5 random seeds = 105 tests)
make test

# Lint all bash scripts with ShellCheck
make shellcheck

# Verify BATS test syntax across all exercises
make bats-check
```

### Grader Reliability Contract
Every exercise in CLI Dojo adheres to the strict CI contract (`ci/run-exercise-ci.sh`):
1. **Fresh State Test:** Untouched exercise must fail grading (prevents vacuous test passes).
2. **Canonical Solution:** `meta/solution.sh` must score 100% green.
3. **Alternative Solutions:** Diverse correct methods (e.g., `cp`+`rm` vs `mv`, `awk` vs `sort|uniq`) in `meta/alt/` must pass.
4. **Deliberately Faulty Solution:** `meta/wrong.sh` must fail grading (prevents overly lenient graders).

---

## 📄 Cheatsheet

A complete CLI cheatsheet covering commands, killer flags, and interview one-liners across all 5 tiers is available at [CHEATSHEET.md](CHEATSHEET.md).

Inside the container, access it anytime with:
```bash
dojo cheat
# or for a specific topic:
dojo cheat networking
```

---

## 📜 License

This project is licensed under the MIT License — see the repository for details.
Built with ❤️ for aspiring Linux systems engineers and DevOps practitioners.
