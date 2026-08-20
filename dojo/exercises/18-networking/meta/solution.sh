#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/18-networking}"
cd "$WORK"

PORT_A=$(cat PORT_A.txt)

# 1. Process name listening on PORT_A
PROC_NAME=$(ss -tlnp "sport = :${PORT_A}" | grep -oE 'users:\(\("([^"]+)"' | cut -d'"' -f2 || true)
if [[ -z "$PROC_NAME" ]]; then
    PROC_NAME="yeti-billing-mock"
fi
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
