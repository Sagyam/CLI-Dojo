#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/05-find}"
    SEED_FILE="/opt/dojo/state/05.seed"
    if [[ -f "$SEED_FILE" ]]; then
        SEED=$(cat "$SEED_FILE")
    else
        SEED=42
    fi
    seed_init "$SEED"
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

@test "old tmp files (>7 days) were deleted from storage/cache/v1" {
    # Check that no tmp files exist in cache/v1
    count_old=$(find "${WORK}/storage/cache/v1" -type f -name "*.tmp" 2>/dev/null | wc -l)
    [ "$count_old" -eq 0 ]
}

@test "recent tmp files (<=7 days) in storage/cache/v2 survived" {
    count_recent=$(find "${WORK}/storage/cache/v2" -type f -name "*.tmp" 2>/dev/null | wc -l)
    [ "$count_recent" -ge 3 ]
}

@test "q1: count of deleted old tmp files matches expected in answers.txt" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_deleted_old_tmp_count")
    [ -n "$got" ]
    
    # In setup: OLD_TMP_COUNT is seeded_int 5 8
    expected=$(seeded_int 5 8)
    [ "$got" -eq "$expected" ]
}

@test "big-files.txt contains sorted list of all files >10MB" {
    [ -f "${WORK}/big-files.txt" ]
    
    # Calculate expected list
    expected=$(find "${WORK}/storage" -type f -size +10M | LC_ALL=C sort)
    actual=$(cat "${WORK}/big-files.txt" | while read -r line; do
        if [[ "$line" == /* ]]; then
            echo "$line"
        else
            # Normalize relative path if given relative to workdir or storage
            if [[ -f "${WORK}/${line}" ]]; then
                realpath "${WORK}/${line}"
            elif [[ -f "${WORK}/storage/${line}" ]]; then
                realpath "${WORK}/storage/${line}"
            else
                echo "$line"
            fi
        fi
    done | LC_ALL=C sort)
    
    expected_real=$(echo "$expected" | while read -r l; do realpath "$l"; done | LC_ALL=C sort)
    [ "$actual" = "$expected_real" ]
}

@test "insecure.txt contains sorted list of world-writable regular files" {
    [ -f "${WORK}/insecure.txt" ]
    
    expected=$(find "${WORK}/storage" -type f -perm -002 | LC_ALL=C sort)
    actual=$(cat "${WORK}/insecure.txt" | while read -r line; do
        if [[ "$line" == /* ]]; then
            echo "$line"
        else
            if [[ -f "${WORK}/${line}" ]]; then
                realpath "${WORK}/${line}"
            elif [[ -f "${WORK}/storage/${line}" ]]; then
                realpath "${WORK}/storage/${line}"
            else
                echo "$line"
            fi
        fi
    done | LC_ALL=C sort)
    
    expected_real=$(echo "$expected" | while read -r l; do realpath "$l"; done | LC_ALL=C sort)
    [ "$actual" = "$expected_real" ]
}

@test "no empty directories remain under storage/" {
    empty_dirs=$(find "${WORK}/storage" -type d -empty | wc -l)
    [ "$empty_dirs" -eq 0 ]
}
