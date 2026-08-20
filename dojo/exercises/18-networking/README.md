# 🎫 Ticket 18 — Who's Listening?
> **From:** Prakash · **Priority:** P2 · **Queue:** Tier 4 — DevOps Flavor

A rogue service appears to be squatting on local ports, and Prakash needs a network socket audit. We also need to test local service routing for our internal domain `billing.yetilink.internal` before registering it in DNS.

*(Lab convenience note: `/etc/hosts` has been pre-configured with group write access for `student` so you can edit it without `sudo`. In real production environments, modifying `/etc/hosts` requires root privileges.)*

## Your tasks
In `~/dojo/18-networking/`:
1. Check `PORT_A.txt` to find the target port number. Identify which process name is listening on this port using `ss -tlnp` (or `lsof -iTCP -sTCP:LISTEN`) and record the process name in `answers.txt` (`q1_portA_process`).
2. List **all** listening TCP port numbers on the container, sorted numerically in ascending order, one port per line, and save to `ports.txt`.
3. Determine the container's primary IPv4 address on `eth0` (using `ip addr` or `ip route`) and record it in `answers.txt` (`q2_container_ip`).
4. Add an entry to `/etc/hosts` mapping IP `127.0.0.1` to hostname `billing.yetilink.internal`.
5. Using `curl`, send an HTTP GET request to `http://billing.yetilink.internal:<PORT_A>/` and save the response body to `hosts-proof.txt`.
6. In `answers.txt`, answer question 3 (`q3_privileged_ports_reason`):
   *Why are standard users unable to bind sockets to ports below 1024 (e.g. port 80)?*
   - `a` — Port numbers below 1024 are reserved solely for UDP broadcasting.
   - `b` — Ports 0–1023 are privileged well-known ports requiring root or `CAP_NET_BIND_SERVICE`.
   - `c` — The Linux TCP stack rejects all non-root port bindings unconditionally.

## Success criteria
Run `dojo check 18`. All rubric checks pass:
- `answers.txt` correctly identifies the process on Port A, container IP, and the privileged ports explanation (`b`).
- `ports.txt` contains all listening TCP port numbers sorted ascending.
- `/etc/hosts` resolves `billing.yetilink.internal` to `127.0.0.1`.
- `hosts-proof.txt` contains the verified JSON response from the billing mock service.

## Stuck?
`dojo hint 18` — three progressive hints.

## 💼 Interview angle
Network troubleshooting using `ss`, `ip`, and local name resolution (`/etc/hosts`, `getent hosts`) is a bread-and-butter SRE interview topic. Expect questions on how to find what process owns a port, why services fail to bind to port 80/443 in unprivileged containers, and the order of name resolution (`/etc/nsswitch.conf`).

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/18-networking

PORT_A=$(cat PORT_A.txt)

# 1. Process name listening on PORT_A
PROC_NAME=$(ss -tlnp "sport = :${PORT_A}" | grep -oE 'users:\(\("([^"]+)"' | cut -d'"' -f2 || ss -tlnp | grep ":${PORT_A} " | grep -oE 'users:\(\("([^"]+)"' | cut -d'"' -f2)
sed -i "s/^q1_portA_process:.*/q1_portA_process: ${PROC_NAME}/" answers.txt

# 2. All listening TCP ports sorted ascending
ss -tlnH | awk '{print $4}' | awk -F: '{print $NF}' | sort -un > ports.txt

# 3. Container eth0 IPv4 address
ETH0_IP=$(ip -4 addr show eth0 2>/dev/null | grep -oE 'inet [0-9.]+' | awk '{print $2}' || hostname -I | awk '{print $1}')
sed -i "s/^q2_container_ip:.*/q2_container_ip: ${ETH0_IP}/" answers.txt

# 4. Add hosts entry if not already present
if ! grep -q "billing.yetilink.internal" /etc/hosts; then
    echo "127.0.0.1 billing.yetilink.internal" >> /etc/hosts
fi

# 5. Fetch mock service via hostname
curl -s "http://billing.yetilink.internal:${PORT_A}/" > hosts-proof.txt

# 6. Privileged port answer
sed -i "s/^q3_privileged_ports_reason:.*/q3_privileged_ports_reason: b/" answers.txt

# 7. Verify
dojo check 18
```
</details>
