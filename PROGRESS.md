# CLI Dojo — Progress Tracker

This document tracks the implementation progress of the CLI Dojo project according to the specifications in `SPEC.md`.

---

## 📊 Summary

- **Overall Status:** Milestone 3 In Progress (Tier 3 Complete, Tier 4 Next)
- **Completed Exercises:** 14 / 21
- **CI Test Suite:** 70 / 105 matrix cells passed

---

## 🏗️ Build Milestones

### Milestone 1 (M1) — Skeleton & Core Loop
- [x] Base Dockerfile (`ubuntu:24.04`, `unminimize`, man-pages, user `student`, groups `ops`/`billing`, pinned tools)
- [x] `docker-compose.yml` & `entrypoint.sh`
- [x] Shell environment & configs (`config/zshrc`, `config/starship.toml`, `config/nvim/init.lua`, `config/motd.txt`)
- [x] Core CLI tools (`dojo/bin/dojo`, `dojo/bin/dojo-setup`, `dojo/bin/dojo-grade`)
- [x] Shared libraries (`dojo/lib/common.sh`, `dojo/lib/seed.sh`)
- [x] Exercise 00 (`00-orientation`) with full meta-test suite
- [x] Meta-test harness (`ci/run-exercise-ci.sh`) & `Makefile`
- [x] GitHub Actions workflow (`.github/workflows/test.yml`)
- [x] M1 CI Validation (Green on Exercise 00 across seeds + shellcheck + bats-check)

### Milestone 2 (M2) — Tiers 1 & 2 (Exercises 01–09)
- [x] `01-navigation` (Scavenger Hunt)
- [x] `02-file-ops` (Shared-Drive Cleanup)
- [x] `03-viewing` (400 MB Router Log)
- [x] `04-help` (RTFM Respectfully)
- [x] `05-find` (Disk Janitor)
- [x] `06-grep` (The Rogue Resolver)
- [x] `07-pipes` (Streams Split and Tamed)
- [x] `08-permissions` (The Billing Drop-Box)
- [x] `09-processes` (The Zombie Cron of Building B)
- [x] M2 CI Validation (Green on Exercises 00–09 across 5 seeds)

### Milestone 3 (M3) — Tiers 3 & 4 (Exercises 10–19)
- [x] `10-columns` (Top Talkers)
- [x] `11-sed` (The Datacenter Move)
- [x] `12-awk` (The Latency Ledger)
- [x] `13-log-capstone` (The 3 AM Access Log)
- [ ] `14-archives` (Restore From the Vault)
- [ ] `15-curl-jq` (Talking to the Customer API)
- [ ] `16-env-path` (The Missing Deploy Tool)
- [ ] `17-users-groups` (The Account Audit)
- [ ] `18-networking` (Who's Listening?)
- [ ] `19-disk` (The 92% Root Partition)
- [ ] M3 CI Validation (Green on Exercises 00–19 across 5 seeds)

### Milestone 4 (M4) — Finale, Cheatsheet & Polish
- [ ] `20-finale` (The Pager Goes Off)
- [ ] `CHEATSHEET.md` (5 tiers + interview one-liners)
- [ ] `README.md` (Student & instructor quickstart)
- [ ] Full Matrix Test Suite (21 exercises × 5 seeds = 105 passed)
- [ ] ShellCheck & Bats syntax validation across repository

---

## 📋 Exercise Status Detail

| # | Exercise Name | Tier | Pattern | Setup | Grader | Hints | Solution | Alt(s) | Wrong | CI (5 Seeds) |
|---|---|---|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 00 | `orientation` | 0 | 1 + Answer | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 01 | `navigation` | 1 | 2 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 02 | `file-ops` | 1 | 1 + Answer | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 03 | `viewing` | 1 | 2 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 04 | `help` | 1 | 2 (Pooled) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 05 | `find` | 2 | 1 + 2 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 06 | `grep` | 2 | 2 + 3 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 07 | `pipes` | 2 | 1 + 2 + 3 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 08 | `permissions` | 2 | 1 + 2 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 09 | `processes` | 2 | 1 + 2 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 10 | `columns` | 3 | 2 + 3 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 11 | `sed` | 3 | 2 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 12 | `awk` | 3 | 2 + 3 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 13 | `log-capstone` | 3 | 2 + 3 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (5/5) |
| 14 | `archives` | 4 | 1 + 2 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| 15 | `curl-jq` | 4 | 1 + 2 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| 16 | `env-path` | 4 | 1 (Shell) | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| 17 | `users-groups` | 4 | 1 + 2 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| 18 | `networking` | 4 | 1 + 2 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| 19 | `disk` | 4 | 1 + 2 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| 20 | `finale` | Finale | 1 + 2 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
