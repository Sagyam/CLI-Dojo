# 🎫 Ticket 14 — Restore From the Vault
> **From:** Suresh dai · **Priority:** P2 · **Queue:** Tier 4 — DevOps Flavor

Someone fat-fingered `etc/radius/radius.conf` right before the evening authentication surge, and AAA services are failing. The only known good copy is archived inside last Tuesday's backup tarball in the `vault/` directory.

We also need tonight's backup generated cleanly: compress the live `etc/` tree using modern `zstd` compression, make sure file paths inside the archive are relative to `etc/` (no top-level `etc/` prefix or absolute paths), and strictly exclude all transient `*.log` files.

## Your tasks
In `~/dojo/14-archives/`:
1. Inspect the backup archive inside `vault/` (named `vault/backup-*.tar.gz`) without extracting the whole thing, and save the complete file listing to `contents.txt`.
2. Extract **only** `radius.conf` from the vault archive and restore it to `etc/radius/radius.conf`, replacing the corrupted file.
3. Create a compressed archive named `backup-today.tar.zst` containing all files in `etc/`, **excluding** all `*.log` files (`--exclude='*.log'`). The archive paths must be relative to the `etc/` directory (e.g. `radius/radius.conf`, not `etc/radius/radius.conf` or `/home/.../etc/...`).
4. Calculate the SHA-256 checksum of the restored `etc/radius/radius.conf` and record the hex digest in `answers.txt` (`q1_radius_sha256`).

## Success criteria
Run `dojo check 14`. All rubric checks pass:
- `contents.txt` lists the files inside the vault backup archive.
- `etc/radius/radius.conf` matches the clean copy from the backup.
- `backup-today.tar.zst` is a valid zstd-compressed tar archive.
- `backup-today.tar.zst` excludes all `*.log` files and uses relative paths within `etc/`.
- `answers.txt` contains the correct SHA-256 hash.

## Stuck?
`dojo hint 14` — three progressive hints.

## 💼 Interview angle
Tar archives and compression algorithms (`gzip`, `bzip2`, `xz`, `zstd`) are universal in Linux operations. Interviewers frequently test whether you know how to inspect archives before extracting (`-t`), extract single files without overwriting the whole filesystem, and use `-C` and `--exclude` to produce clean container or system backups.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/14-archives

# 1. List archive contents into contents.txt
VAULT_TAR=$(ls vault/backup-*.tar.gz)
tar -tf "$VAULT_TAR" > contents.txt

# 2. Extract only radius.conf into place
# Find exact path within archive from contents.txt
RADIUS_PATH=$(grep "radius\.conf$" contents.txt)
tar -xzf "$VAULT_TAR" "$RADIUS_PATH"

# 3. Create tonight's backup with zstd, excluding *.log and stripping etc/ prefix
tar --zstd -cf backup-today.tar.zst -C etc --exclude='*.log' .

# 4. Record SHA256 checksum in answers.txt
SHA=$(sha256sum etc/radius/radius.conf | awk '{print $1}')
sed -i "s/^q1_radius_sha256:.*/q1_radius_sha256: ${SHA}/" answers.txt

# 5. Verify
dojo check 14
```
</details>
