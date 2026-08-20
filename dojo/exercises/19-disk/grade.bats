#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/19-disk}"
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

@test "top3-dirs.txt contains the 3 largest directories in descending order" {
    [ -f "${WORK}/top3-dirs.txt" ]
    [ -s "${WORK}/top3-dirs.txt" ]
    
    # Normalize by stripping path prefixes and whitespace
    dirs=($(awk 'NF {gsub(/^(disk-arena\/|\.\/)/, ""); gsub(/\/$/, ""); print $NF}' "${WORK}/top3-dirs.txt"))
    [ "${#dirs[@]}" -ge 3 ]
    
    [ "${dirs[0]}" = "logs" ]
    [ "${dirs[1]}" = "backups" ]
    [ "${dirs[2]}" = "cache" ]
}

@test "disk-arena/cache directory has been deleted" {
    [ ! -d "${WORK}/disk-arena/cache" ]
}

@test "disk-arena/app.log was truncated without killing the writer" {
    [ -f "${WORK}/disk-arena/app.log" ]
    
    # Check that file size is under 50KB (down from 5MB)
    size=$(stat -c "%s" "${WORK}/disk-arena/app.log")
    [ "$size" -lt 50000 ]
}

@test "yeti-log-writer process is still running" {
    pgrep -f "yeti-log-writer" >/dev/null 2>&1
}

@test "q1: fullest mount point in answers.txt is /var/log" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_fullest_mount" | sed 's/\/$//')
    [ -n "$got" ]
    [ "$got" = "/var/log" ]
}

@test "q2: open file deletion behavior in answers.txt is option c" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_rm_open_file_reason" | tr '[:upper:]' '[:lower:]')
    [ "$got" = "c" ]
}
