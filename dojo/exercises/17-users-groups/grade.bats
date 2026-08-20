#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/17-users-groups}"
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

@test "q1: UID of target audit user matches /etc/passwd" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_target_user_uid")
    [ -n "$got" ]
    
    target=$(cat "${WORK}/TARGET_USER.txt" 2>/dev/null || echo "suresh_ops")
    expected=$(id -u "$target" 2>/dev/null || true)
    [ -n "$expected" ]
    [ "$got" -eq "$expected" ]
}

@test "q2: count of accounts with valid login shells matches /etc/passwd" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_real_shell_count")
    [ -n "$got" ]
    
    expected=$(grep -vE '(nologin|false|sync)$' /etc/passwd | wc -l)
    [ "$got" -eq "$expected" ]
}

@test "q3: non-root user in sudo group identified correctly in answers.txt" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q3_sudo_user")
    [ -n "$got" ]
    
    expected=$(getent group sudo | cut -d: -f4 | tr ',' '\n' | grep -v '^root$' | head -n 1)
    [ "$got" = "$expected" ]
}

@test "q4: GID of billing group matches /etc/group in answers.txt" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q4_billing_gid")
    [ -n "$got" ]
    
    expected=$(getent group billing | cut -d: -f3)
    [ "$got" -eq "$expected" ]
}

@test "q5: login shell field number in /etc/passwd is 7 in answers.txt" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q5_passwd_shell_field_number")
    [ -n "$got" ]
    [ "$got" -eq 7 ]
}

@test "/home/tara/proof.txt exists and is owned by tara:tara" {
    [ -f "/home/tara/proof.txt" ]
    [ -s "/home/tara/proof.txt" ]
    
    owner=$(stat -c "%U" /home/tara/proof.txt)
    [ "$owner" = "tara" ]
}

@test "/home/tara/proof.txt contains valid id output for user tara" {
    [ -f "/home/tara/proof.txt" ]
    grep -E "uid=[0-9]+\(tara\)" /home/tara/proof.txt
}
