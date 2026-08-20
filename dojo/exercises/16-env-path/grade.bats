#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/16-env-path}"
}

run_zsh_cmd() {
    local cmd="$1"
    if command -v gosu >/dev/null 2>&1 && [[ "$(id -u)" -eq 0 ]] && id student >/dev/null 2>&1; then
        timeout 10 gosu student zsh -ic "$cmd" 2>/dev/null
    elif [[ "$(id -u)" -eq 0 ]] && id student >/dev/null 2>&1; then
        timeout 10 su -s /bin/zsh - student -c "$cmd" 2>/dev/null
    else
        timeout 10 zsh -ic "$cmd" 2>/dev/null
    fi
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

@test "~/.zshrc loads cleanly in an interactive shell without errors" {
    run run_zsh_cmd "exit 0"
    [ "$status" -eq 0 ]
}

@test "yetideploy is resolvable in an interactive login shell" {
    res=$(run_zsh_cmd "command -v yetideploy" | tail -n 1)
    [ -n "$res" ]
    [[ "$res" =~ yetideploy$ ]]
}

@test "YETI_ENV is exported in interactive shell matching assigned environment" {
    got=$(run_zsh_cmd "printenv YETI_ENV" | tail -n 1)
    [ -n "$got" ]
    
    if [[ -f "${WORK}/.expected_env" ]]; then
        expected=$(cat "${WORK}/.expected_env")
        [ "$got" = "$expected" ]
    fi
}

@test "YETI_REGION is exported as ap-south-1 in interactive shell" {
    got=$(run_zsh_cmd "printenv YETI_REGION" | tail -n 1)
    [ "$got" = "ap-south-1" ]
}

@test "token.txt exists and contains valid deployment token" {
    [ -f "${WORK}/token.txt" ]
    [ -s "${WORK}/token.txt" ]
    
    if [[ -f "${WORK}/.expected_token" ]]; then
        expected=$(cat "${WORK}/.expected_token")
        actual=$(tr -d '[:space:]' < "${WORK}/token.txt")
        [ "$actual" = "$expected" ]
    fi
}

@test "q1: first directory in login shell PATH matches answers.txt" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "q1_first_path_dir")
    [ -n "$got" ]
    
    expected=$(run_zsh_cmd "echo \$PATH" | tail -n 1 | cut -d: -f1)
    [ "$got" = "$expected" ]
}
