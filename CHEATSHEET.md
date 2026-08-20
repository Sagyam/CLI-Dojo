# YetiLink Linux CLI Cheatsheet

Quick-reference cheatsheet for Systems Engineers and DevOps Bootcampers.

---

## Tier 0 & 1 — Terminal Survival & Fundamentals

| Command | Purpose | Killer Flags / Common Patterns |
|---|---|---|
| `whoami` / `id` | Show current user & group IDs | `id -u` (numeric uid), `id -Gn` (group names) |
| `hostname` | Print system network name | `hostname -I` (all IP addresses) |
| `pwd` | Print current working directory | `pwd -P` (resolve physical path without symlinks) |
| `cd` | Change directory | `cd -` (previous dir), `cd ~` (home) |
| `ls` | List directory contents | `ls -la` (all+long), `ls -lh` (human sizes), `ls -lt` (by time), `ls -lS` (by size) |
| `mkdir` | Make directories | `mkdir -p path/to/nested` (create parents) |
| `cp` | Copy files / directories | `cp -r src/ dest/`, `cp -a` (preserve all attributes) |
| `mv` | Move or rename files | `mv -n` (no overwrite), `mv -i` (prompt) |
| `rm` | Remove files / directories | `rm -r dir/` (recursive), `rm -f` (force without prompt) |
| `touch` | Create empty file or update timestamps | `touch -d '2 days ago' file.txt` |
| `ln` | Create hard or symbolic links | `ln -s /target linkname` (symlink), `ln target linkname` (hardlink) |
| `stat` | View detailed inode & file metadata | `stat -c %a file` (octal perms), `stat -c %i file` (inode number) |
| `file` | Determine file type from magic bytes | `file -b file` (brief mode), `file -i file` (mime type) |
| `head` / `tail` | Output beginning or end of files | `head -n 20`, `tail -n 20`, `tail -f file.log` (follow), `tail -n +5` (from line 5) |
| `less` | Interactive file pager | `/pattern` (search), `n`/`N` (next/prev), `G` (end), `1G` (start), `q` (quit) |
| `wc` | Word, line, and byte count | `wc -l` (lines only), `wc -w` (words), `wc -c` (bytes) |
| `man` / `apropos` | Manual pages & keyword search | `man 5 crontab` (file formats), `man 8 iptables` (sysadmin), `apropos keyword` |
| `type` / `which` | Identify command binary or builtin | `type -a cmd`, `which cmd` |

> [!TIP]
> ### 💼 Interview One-Liners (Tier 1)
> - **Find file type ignoring misleading extension:** `file suspicious.conf`
> - **Follow a log file that rotates:** `tail -F /var/log/syslog`
> - **Find which man section a topic is in:** `man -k crontab` or `apropos crontab`
> - **Difference between hard link & symlink:** A symlink points to a path (breaks if target moves); a hard link shares the target's inode number (survives target deletion, restricted to same filesystem).

---

## Tier 2 — Search, Redirection & Process Management

| Command | Purpose | Killer Flags / Common Patterns |
|---|---|---|
| `find` | Powerful filesystem search | `find . -name "*.log"`, `find . -type f -size +100M`, `find . -mtime -1` |
| `grep` | Match patterns in text/files | `grep -rnI "pattern" .` (recursive, line num, skip binary), `grep -v` (invert), `grep -E` (regex) |
| `sort` | Sort lines of text | `sort -n` (numeric), `sort -r` (reverse), `sort -k2,2` (by column 2), `sort -u` (unique) |
| `uniq` | Report or omit repeated lines | `uniq -c` (count occurrences), `uniq -d` (only duplicates) — *input must be sorted!* |
| `tee` | Read from stdin and write to stdout & files | `cmd \| tee out.log`, `cmd \| tee -a append.log` |
| `xargs` | Build and execute command lines from stdin | `find . -name "*.tmp" \| xargs rm -f`, `xargs -I{} cp {} /dest/` |
| `chmod` | Change file mode bits | `chmod 755 script.sh`, `chmod 640 secret.txt`, `chmod 2770 dir` (setgid), `chmod 1777 /tmp` (sticky) |
| `chown` / `chgrp` | Change file owner and group | `chown -R student:ops dir/`, `chgrp billing file.csv` |
| `ps` | Report process snapshot | `ps aux`, `ps -ef`, `ps aux --sort=-%mem \| head -n 10` |
| `pgrep` / `pkill` | Look up or signal processes by name | `pgrep -fl python`, `pkill -15 -f worker` |
| `kill` | Send signal to process | `kill -15 <PID>` (SIGTERM, polite), `kill -9 <PID>` (SIGKILL, uncatchable) |
| `nohup` | Run command immune to hangups | `nohup python3 server.py > server.log 2>&1 &` |

> [!TIP]
> ### 💼 Interview One-Liners (Tier 2)
> - **Find files >100MB modified in the last 24 hours:** `find / -type f -size +100M -mtime -1 2>/dev/null`
> - **Search recursively for an IP without regex escapes:** `grep -rnF "10.10.0.53" /etc/`
> - **Redirect both stdout and stderr to a log file:** `command > output.log 2>&1` (or modern `command &> output.log`)
> - **Why `2>&1 >file` fails:** Shell evaluates left-to-right; stderr duplicates current stdout (terminal), then stdout redirects to file, leaving stderr on terminal.
> - **Find top 5 memory hogs:** `ps aux --sort=-%mem | head -n 6`
> - **Uncatchable signals:** Signal 9 (`SIGKILL`) and Signal 19 (`SIGSTOP`) cannot be caught, blocked, or ignored.

---

## Tier 3 — Text Processing & Log Forensics

| Command | Purpose | Killer Flags / Common Patterns |
|---|---|---|
| `cut` | Remove sections from each line | `cut -d',' -f1,3 data.csv`, `cut -d':' -f1 /etc/passwd` |
| `tr` | Translate, squeeze, or delete characters | `tr 'A-Z' 'a-z'`, `tr -s ' '` (squeeze spaces), `tr -d '\r'` (strip CRLF) |
| `sed` | Stream editor for filtering and transforming | `sed 's/foo/bar/g' file.txt`, `sed -i.bak 's/old/new/g' *.conf`, `sed '/pattern/d'` (delete lines) |
| `awk` | Pattern scanning and text processing language | `awk '{print $1, $NF}'`, `awk -F: '$3 >= 1000 {print $1}' /etc/passwd` |

> [!TIP]
> ### 💼 Interview One-Liners (Tier 3)
> - **Top 5 IP addresses in an Nginx access log:** `awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -n 5`
> - **Count HTTP status codes:** `awk '{print $9}' access.log | sort | uniq -c | sort -nr`
> - **Sum numbers in column 4:** `awk '{sum += $4} END {print sum}' data.txt`
> - **In-place replace exact word boundary:** `sed -i 's/\bblr1\.yetilink\.internal\b/ktm2.yetilink.internal/g' *.conf`
> - **Print lines 10 to 20 of a file:** `sed -n '10,20p' file.txt`

---

## Tier 4 — DevOps & Systems Diagnostics

| Command | Purpose | Killer Flags / Common Patterns |
|---|---|---|
| `tar` | Archive utility | `tar -czvf backup.tar.gz -C /path etc/` (create), `tar -xvf backup.tar.gz` (extract) |
| `tar` single file | Extract single file from tarball | `tar -xvf backup.tar.gz etc/radius.conf --strip-components=1` |
| `curl` | Transfer data from or to a server | `curl -s -i -H "Content-Type: application/json" -X POST -d '{"k":"v"}' http://url` |
| `jq` | Command-line JSON processor | `jq -r '.data[].name'`, `jq 'map(select(.plan == "premium"))'` |
| `df` / `du` | Disk free and disk usage | `df -h` (human filesystem capacity), `du -sh * \| sort -h` (sorted directory sizes) |
| `truncate` | Shrink or extend file size to specified size | `truncate -s 0 /var/log/app.log` (free space of open file without breaking handle) |
| `ss` | Socket statistics (modern `netstat`) | `ss -tulpn` (all listening TCP/UDP with PIDs), `ss -ta` (all TCP sockets) |
| `ip` | Show / manipulate routing, devices, interfaces | `ip addr show eth0`, `ip route show` |
| `dig` / `nslookup`| DNS lookup utility | `dig +short domain.com`, `dig @8.8.8.8 domain.com MX` |
| `su` / `sudo` | Switch user / execute command as superuser | `su - username` (login shell), `sudo -l` (list permitted commands) |

> [!TIP]
> ### 💼 Interview One-Liners (Tier 4)
> - **Why didn't `rm` free disk space?** A running process still holds an open file descriptor to the deleted file. Identify it with `lsof +L1` or `lsof | grep deleted`, and either restart the daemon or truncate the fd via `/proc/<PID>/fd/<FD>`.
> - **Safely zero a bloated log without restarting service:** `truncate -s 0 /var/log/bloat.log` or `: > /var/log/bloat.log`
> - **Check which process is listening on port 8080:** `ss -tlnp 'sport = :8080'` or `lsof -i :8080`
> - **Audit all users with interactive login shells:** `awk -F: '$7 !~ /(nologin|false)$/ {print $1, $7}' /etc/passwd`
