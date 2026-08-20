#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/18-networking}"
    PORT_A=$(cat "${WORK}/PORT_A.txt" 2>/dev/null || echo "9100")
}

get_answer() {
    local key="$1"
    awk -F ':' -v k="$key" '
        $1 ~ "^[[:space:]]*" k "[[:space:]]*$" {
            val = substr($0, index($0, ":") + 1)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
            print val
        }
    ' "${WORK}/answers.txt"
}

@test "q1: process name on PORT_A correctly identified in answers.txt" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_portA_process")
    [ -n "$got" ]
    
    # Process is yeti-billing-mock or python3
    [[ "$got" =~ "yeti-billing-mock" || "$got" =~ "python" ]]
}

@test "ports.txt exists and contains all listening TCP ports sorted ascending" {
    [ -f "${WORK}/ports.txt" ]
    [ -s "${WORK}/ports.txt" ]
    
    actual_ports=$(tr -d '\r' < "${WORK}/ports.txt" | awk 'NF' | sort -n)
    expected_ports=$(ss -tlnH | awk '{print $4}' | awk -F: '{print $NF}' | sort -un)
    
    [ "$actual_ports" = "$expected_ports" ]
}

@test "q2: container IP in answers.txt matches active IPv4 address" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_container_ip")
    [ -n "$got" ]
    
    eth0_ip=$(ip -4 addr show eth0 2>/dev/null | grep -oE 'inet [0-9.]+' | awk '{print $2}' || true)
    all_ips=$(hostname -I 2>/dev/null || true)
    
    [[ "$all_ips" =~ $got || "$eth0_ip" = "$got" ]]
}

@test "/etc/hosts contains valid mapping for billing.yetilink.internal to 127.0.0.1" {
    grep -E "^127\.0\.0\.1[[:space:]]+.*billing\.yetilink\.internal" /etc/hosts
}

@test "hosts-proof.txt exists and contains verified JSON response" {
    [ -f "${WORK}/hosts-proof.txt" ]
    [ -s "${WORK}/hosts-proof.txt" ]
    
    grep -q '"status": "billing_ok"' "${WORK}/hosts-proof.txt"
    if [[ -f "${WORK}/.expected_token" ]]; then
        expected_token=$(cat "${WORK}/.expected_token")
        grep -q "$expected_token" "${WORK}/hosts-proof.txt"
    fi
}

@test "q3: privileged ports restriction identified as option b" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q3_privileged_ports_reason" | tr '[:upper:]' '[:lower:]')
    [ "$got" = "b" ]
}
