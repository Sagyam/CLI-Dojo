#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/14-archives}"
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

@test "contents.txt exists and is non-empty" {
    [ -f "${WORK}/contents.txt" ]
    [ -s "${WORK}/contents.txt" ]
}

@test "contents.txt accurately lists files in the backup archive" {
    [ -f "${WORK}/contents.txt" ]
    grep -E "(^|/)radius\.conf$" "${WORK}/contents.txt"
    grep -E "(^|/)dhcpd\.conf$" "${WORK}/contents.txt"
}

@test "etc/radius/radius.conf exists and matches clean backup copy" {
    [ -f "${WORK}/etc/radius/radius.conf" ]
    ! grep -q "INVALID_SYNTAX" "${WORK}/etc/radius/radius.conf"
    
    if [[ -f "${WORK}/.good_radius_sha256" ]]; then
        expected_sha=$(cat "${WORK}/.good_radius_sha256")
        actual_sha=$(sha256sum "${WORK}/etc/radius/radius.conf" | awk '{print $1}')
        [ "$actual_sha" = "$expected_sha" ]
    fi
}

@test "backup-today.tar.zst exists and is valid zstd tar archive" {
    [ -f "${WORK}/backup-today.tar.zst" ]
    tar --zstd -tf "${WORK}/backup-today.tar.zst" >/dev/null
}

@test "backup-today.tar.zst paths are relative to etc/ (no etc/ prefix or absolute /)" {
    [ -f "${WORK}/backup-today.tar.zst" ]
    entries=$(tar --zstd -tf "${WORK}/backup-today.tar.zst")
    
    # Assert no entry begins with /
    ! echo "$entries" | grep -E '^/'
    # Assert no entry begins with etc/
    ! echo "$entries" | grep -E '^etc/'
}

@test "backup-today.tar.zst excludes all *.log files" {
    [ -f "${WORK}/backup-today.tar.zst" ]
    entries=$(tar --zstd -tf "${WORK}/backup-today.tar.zst")
    ! echo "$entries" | grep -E '\.log$'
}

@test "backup-today.tar.zst contains configuration files" {
    [ -f "${WORK}/backup-today.tar.zst" ]
    entries=$(tar --zstd -tf "${WORK}/backup-today.tar.zst")
    echo "$entries" | grep -E '(^|/|\.)(radius/)?radius\.conf$'
    echo "$entries" | grep -E '(^|/|\.)(dhcp/)?dhcpd\.conf$'
}

@test "q1: SHA256 checksum in answers.txt matches restored radius.conf" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_radius_sha256" | tr '[:upper:]' '[:lower:]')
    [ -n "$got" ]
    
    if [[ -f "${WORK}/.good_radius_sha256" ]]; then
        expected=$(cat "${WORK}/.good_radius_sha256" | tr '[:upper:]' '[:lower:]')
        [ "$got" = "$expected" ]
    fi
}
