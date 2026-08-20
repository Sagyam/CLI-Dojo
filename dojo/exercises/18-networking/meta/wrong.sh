#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/18-networking}"
cd "$WORK"

# Wrong solution:
# 1. Wrong process name
sed -i "s/^q1_portA_process:.*/q1_portA_process: unknown_daemon/" answers.txt

# 2. Unsorted ports
echo "9999" > ports.txt
echo "1111" >> ports.txt

# 3. Wrong IP
sed -i "s/^q2_container_ip:.*/q2_container_ip: 192.168.1.1/" answers.txt

# 4. Wrong privileged ports answer
sed -i "s/^q3_privileged_ports_reason:.*/q3_privileged_ports_reason: a/" answers.txt

# 5. Wrong proof
echo "bad proof" > hosts-proof.txt
