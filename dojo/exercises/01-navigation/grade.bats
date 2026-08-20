#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/01-navigation}"
    SEED_FILE="/opt/dojo/state/01.seed"
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

@test "q1: treasure absolute path is correct" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_treasure_path")
    [ -n "$got" ]
    
    # Calculate real treasure path
    expected=$(find "${WORK}/fake-root" -name "treasure.txt" | head -n1)
    [ "$got" = "$expected" ]
}

@test "q2: size in bytes of largest file under fake-root/var matches" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_largest_var_bytes")
    [ -n "$got" ]
    
    expected=$(find "${WORK}/fake-root/var" -type f -exec stat -c %s {} + | sort -n | tail -n1)
    [ "$got" -eq "$expected" ]
}

@test "q3: disguised file real type identified as PNG image" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q3_disguised_file_type" | tr '[:upper:]' '[:lower:]')
    [ -n "$got" ]
    
    # Check that answer contains 'png'
    [[ "$got" == *"png"* ]]
}

@test "q4: count of hidden files in fake-root/opt/backup is correct" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q4_hidden_file_count")
    [ -n "$got" ]
    
    expected=$(find "${WORK}/fake-root/opt/backup" -maxdepth 1 -name ".*" ! -name "." ! -name ".." | wc -l)
    [ "$got" -eq "$expected" ]
}

@test "q5: relative path option identified correctly" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q5_relative_path_choice" | tr '[:upper:]' '[:lower:]')
    [ "$got" = "b" ]
}
