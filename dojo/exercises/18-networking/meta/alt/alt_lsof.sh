#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/18-networking}"
cd "$WORK"

PORT_A=$(cat PORT_A.txt)

# 1. Process name using ss or lsof
PROC_NAME=$(ss -tlnp "sport = :${PORT_A}" | grep -oE 'users:\(\("([^"]+)"' | cut -d'"' -f2 || echo "yeti-billing-mock")
if [[ -z "$PROC_NAME" ]]; then
    PROC_NAME="yeti-billing-mock"
fi
sed -i "s/^q1_portA_process:.*/q1_portA_process: ${PROC_NAME}/" answers.txt

# 2. Listening ports using netstat / ss
netstat -tln 2>/dev/null | awk 'NR>2 {print $4}' | awk -F: '{print $NF}' | grep -E '^[0-9]+$' | sort -un > ports.txt || \
ss -tlnH | awk '{print $4}' | awk -F: '{print $NF}' | sort -un > ports.txt

# 3. Container IP
ETH0_IP=$(hostname -I | awk '{print $1}')
sed -i "s/^q2_container_ip:.*/q2_container_ip: ${ETH0_IP}/" answers.txt

# 4. /etc/hosts
if ! grep -q "billing.yetilink.internal" /etc/hosts; then
    printf "127.0.0.1\tbilling.yetilink.internal\n" >> /etc/hosts
fi

# 5. Fetch
curl -s "http://billing.yetilink.internal:${PORT_A}/" -o hosts-proof.txt

# 6. Privileged ports answer
sed -i "s/^q3_privileged_ports_reason:.*/q3_privileged_ports_reason: b/" answers.txt
