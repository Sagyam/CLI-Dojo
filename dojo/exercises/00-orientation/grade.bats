#!/usr/bin/env bats

setup() {
    # Support both in-container /opt/bats and standard local load paths
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/00-orientation}"
    PROGRESS_FILE="${DOJO_PROGRESS_FILE:-/home/student/.dojo/progress.json}"
}

@test "hello.txt exists in ~/dojo/00-orientation/" {
    [ -f "${WORK}/hello.txt" ]
}

@test "hello.txt contains current username 'student'" {
    [ -f "${WORK}/hello.txt" ]
    content=$(tr -d '[:space:]' < "${WORK}/hello.txt")
    [ "$content" = "student" ]
}

@test "answers.txt contains correct hostname 'yetilink-ops-01'" {
    [ -f "${WORK}/answers.txt" ]
    val=$(awk -F ':' '/^[[:space:]]*q1_hostname[[:space:]]*:/ {print $2}' "${WORK}/answers.txt" | tr -d '[:space:]')
    [ "$val" = "yetilink-ops-01" ]
}

@test "at least one hint was revealed for ticket 00" {
    [ -f "$PROGRESS_FILE" ]
    hints=$(jq -r '.exercises["00"].hints // 0' "$PROGRESS_FILE" 2>/dev/null || echo "0")
    [ "$hints" -ge 1 ]
}
