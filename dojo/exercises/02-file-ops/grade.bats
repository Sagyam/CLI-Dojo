#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/02-file-ops}"
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

@test "contracts directory tree exists (contracts/2023, 2024, 2025)" {
    [ -d "${WORK}/contracts/2023" ]
    [ -d "${WORK}/contracts/2024" ]
    [ -d "${WORK}/contracts/2025" ]
}

@test "all contracts correctly filed into their respective year directory" {
    # Check that 2023 contains 2023 files
    count_2023=$(find "${WORK}/contracts/2023" -type f -name "*2023.pdf" | wc -l)
    [ "$count_2023" -ge 6 ]
    
    count_2024=$(find "${WORK}/contracts/2024" -type f -name "*2024.pdf" | wc -l)
    [ "$count_2024" -ge 7 ]
    
    count_2025=$(find "${WORK}/contracts/2025" -type f -name "*2025.pdf" | wc -l)
    [ "$count_2025" -ge 6 ]
}

@test "misspelled contract was renamed to client_kathmandu_2024.pdf" {
    [ -f "${WORK}/contracts/2024/client_kathmandu_2024.pdf" ]
    [ ! -f "${WORK}/contracts/2024/client_katmandu_2024.pdf" ]
}

@test "junk files and raw_contracts directory were deleted" {
    [ ! -d "${WORK}/raw_contracts" ]
    find_junk=$(find "${WORK}" -name "*.tmp" -o -name ".DS_Store" -o -name "*.bak" | wc -l)
    [ "$find_junk" -eq 0 ]
}

@test "config-current.yaml exists as a symlink pointing to config-2025.yaml" {
    [ -L "${WORK}/config-current.yaml" ]
    target=$(readlink "${WORK}/config-current.yaml")
    [[ "$target" == *"config-2025.yaml"* ]]
}

@test "config-backup.yaml exists as a regular file with valid content and config-2025.yaml is removed" {
    [ ! -f "${WORK}/config-2025.yaml" ]
    [ -f "${WORK}/config-backup.yaml" ]
    [ ! -L "${WORK}/config-backup.yaml" ]
    grep -q "2025-active-prod" "${WORK}/config-backup.yaml"
}

@test "answers.txt identifies the surviving link and its link count of 1" {
    [ -f "${WORK}/answers.txt" ]
    q1=$(get_answer "q1_surviving_link_type" | tr '[:upper:]' '[:lower:]')
    q2=$(get_answer "q2_survivor_link_count")
    
    [[ "$q1" == *"config-backup"* || "$q1" == *"hard"* ]]
    [ "$q2" -eq 1 ]
}
