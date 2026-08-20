#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/08-permissions}"
    
    SEED_FILE="/opt/dojo/state/08.seed"
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

@test "dropbox/ group is set to billing" {
    [ -d "${WORK}/dropbox" ]
    group=$(stat -c %G "${WORK}/dropbox")
    [ "$group" = "billing" ]
}

@test "dropbox/ has mode 2770 (setgid + rwxrwx---)" {
    [ -d "${WORK}/dropbox" ]
    mode=$(stat -c %a "${WORK}/dropbox")
    [ "$mode" = "2770" ]
}

@test "deploy.sh has mode 750 (rwxr-x---)" {
    [ -f "${WORK}/deploy.sh" ]
    mode=$(stat -c %a "${WORK}/deploy.sh")
    [ "$mode" = "750" ] || [ "$mode" = "0750" ]
}

@test "secret-salaries.csv has mode 400 (r--------)" {
    [ -f "${WORK}/secret-salaries.csv" ]
    mode=$(stat -c %a "${WORK}/secret-salaries.csv")
    [ "$mode" = "400" ] || [ "$mode" = "0400" ]
}

@test "shared-tmp/ exists with mode 1777 (sticky bit + rwxrwxrwt)" {
    [ -d "${WORK}/shared-tmp" ]
    mode=$(stat -c %a "${WORK}/shared-tmp")
    [ "$mode" = "1777" ]
}

@test "q1: octal mode in answers.txt accurately matches the quiz permission string" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_octal_mode")
    [ -n "$got" ]
    
    if [[ -f "${WORK}/.octal_answer" ]]; then
        expected=$(cat "${WORK}/.octal_answer" | tr -d '[:space:]')
    else
        OCTAL_MODES=(
            "751:-rwxr-x--x"
            "651:-rw-r-x--x"
            "740:-rwxr-----"
            "640:-rw-r-----"
            "754:-rwxr-xr--"
            "664:-rw-rw-r--"
        )
        PICKED=$(seeded_pick "${OCTAL_MODES[@]}")
        expected=$(echo "$PICKED" | cut -d: -f1)
    fi
    
    [ "$got" -eq "$expected" ]
}

@test "q2: umask value producing 640 default file permissions is correct" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_umask_for_640")
    [ -n "$got" ]
    
    # 666 - 640 = 026 / 027 (umask 027 masks out read+write+execute for others: 666 & ~027 = 640)
    got_int=$((10#$got))
    [ "$got_int" -eq 27 ]
}
