# 🎫 Ticket 11 — The Datacenter Move
> **From:** Suresh dai · **Priority:** P1 · **Queue:** Tier 3 — Text Processing

We just stood up our new secondary datacenter in Kathmandu (`ktm2`), and the Bangalore legacy node (`blr1`) is getting decommissioned at the end of the week. There are 60 node configuration files in `configs/` pointing at `blr1.yetilink.internal`. You are not opening 60 files by hand in an editor.

Also, the old overlay network directive `use_flannel` has been completely deprecated and must be purged from all configs, and we need to comment out obsolete modules in `nginx.conf`.

## Your tasks
In `~/dojo/11-sed/`:
1. Replace all exact occurrences of the hostname `blr1.yetilink.internal` with `ktm2.yetilink.internal` across all 60 files in `configs/*.conf` in-place, creating backup files with a `.bak` extension (e.g. `sed -i.bak ...`).
   - ⚠️ **Caution:** Do **not** modify near-miss hostnames such as `blr1.yetilink.internal_backup` or `node_blr1.yetilink.internal`! Match exact hostname word boundaries (`\b`).
2. In all 60 files in `configs/*.conf`, delete every line containing the deprecated directive `use_flannel`.
3. In `nginx.conf`, comment out every line containing `deprecated_module` by prefixing it with `# ` (e.g. `# load_module modules/ngx_deprecated_module.so;`).
4. Using `sed -n`, extract exactly lines 10 through 20 (inclusive) of `nginx.conf` and save the result to `preview.txt`.

## Success criteria
Run `dojo check 11`. All rubric checks pass.

## Stuck?
`dojo hint 11` — three progressive hints.

## 💼 Interview angle
Stream editing (`sed`) with in-place flags (`-i`), word boundary anchors (`\b` or `\<...\>`), line deletions (`/pattern/d`), and address ranges (`10,20p`) separates engineers who write robust automation scripts from those who accidentally corrupt production configuration fleets.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/11-sed

# 1. Replace exact hostname with .bak backup
sed -i.bak 's/\bblr1\.yetilink\.internal\b/ktm2.yetilink.internal/g' configs/*.conf

# 2. Delete deprecated use_flannel lines
sed -i '/use_flannel/d' configs/*.conf

# 3. Comment out deprecated modules in nginx.conf
sed -i '/deprecated_module/s/^/# /' nginx.conf

# 4. Extract lines 10 to 20 to preview.txt
sed -n '10,20p' nginx.conf > preview.txt

# 5. Verify
dojo check 11
```
</details>
