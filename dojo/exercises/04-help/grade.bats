#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/04-help}"
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

@test "q1: crontab file format is documented in section 5" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_crontab_format_section")
    [ "$got" -eq 5 ]
}

@test "q2: cd command identified as a shell builtin" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q2_cd_type" | tr '[:upper:]' '[:lower:]')
    [[ "$got" == *"builtin"* ]]
}

@test "q3: full path of awk binary is /usr/bin/awk or /usr/bin/gawk" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q3_awk_binary_path")
    [[ "$got" == "/usr/bin/awk" || "$got" == "/usr/bin/gawk" || "$got" == "/bin/awk" ]]
}

@test "q4: typescript command identified as script via apropos" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q4_typescript_cmd" | tr '[:upper:]' '[:lower:]')
    [ "$got" = "script" ]
}

@test "q5: system administration commands are documented in section 8" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q5_sysadmin_man_section")
    [ "$got" -eq 8 ]
}
