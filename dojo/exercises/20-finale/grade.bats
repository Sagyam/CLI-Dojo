#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/20-finale}"
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

# ==============================================================================
# --- Ticket 1: Disk Bloat ---
# ==============================================================================

@test "Ticket 1: incident/app.log was truncated to near 0 bytes" {
    [ -f "${WORK}/incident/app.log" ]
    size=$(stat -c "%s" "${WORK}/incident/app.log")
    [ "$size" -lt 50000 ]
}

@test "Ticket 1: yeti-live-logger is still running and app.log was not deleted" {
    [ -f "${WORK}/incident/app.log" ]
    pgrep -f "yeti-live-logger" >/dev/null 2>&1
}

# ==============================================================================
# --- Ticket 2: Rogue Process ---
# ==============================================================================

@test "Ticket 2: stubbornd process is terminated" {
    ! pgrep -f "^stubbornd" >/dev/null 2>&1
}

@test "Ticket 2: legitimate service yeti-authd remains running" {
    pgrep -f "^yeti-authd" >/dev/null 2>&1
}

# ==============================================================================
# --- Ticket 3: Config Grep ---
# ==============================================================================

@test "Ticket 3: t3_rogue_file.txt identifies the rogue configuration file" {
    [ -f "${WORK}/t3_rogue_file.txt" ]
    [ -s "${WORK}/t3_rogue_file.txt" ]
    
    got=$(cat "${WORK}/t3_rogue_file.txt" | tr -d '[:space:]')
    if [[ -f "${WORK}/.expected_rogue_file" ]]; then
        expected=$(cat "${WORK}/.expected_rogue_file" | tr -d '[:space:]')
        # Allow relative to workdir or relative to incident
        [[ "$got" = "$expected" || "$got" = "incident/$expected" || "incident/$got" = "$expected" || "$(basename "$got")" = "$(basename "$expected")" ]]
    fi
}

@test "Ticket 3: t3_rogue_val in answers.txt matches the rogue IP" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "t3_rogue_val")
    [ -n "$got" ]
    
    if [[ -f "${WORK}/.expected_rogue_ip" ]]; then
        expected=$(cat "${WORK}/.expected_rogue_ip")
        [ "$got" = "$expected" ]
    fi
}

# ==============================================================================
# --- Ticket 4: Permissions ---
# ==============================================================================

@test "Ticket 4: incident/secure/billing.conf permissions restored to 640" {
    [ -f "${WORK}/incident/secure/billing.conf" ]
    perms=$(stat -c "%a" "${WORK}/incident/secure/billing.conf")
    [ "$perms" = "640" ]
}

# ==============================================================================
# --- Ticket 5: Log Forensics ---
# ==============================================================================

@test "Ticket 5: t5_top3_ips.txt contains the top 3 client IPs in descending order" {
    [ -f "${WORK}/t5_top3_ips.txt" ]
    [ -s "${WORK}/t5_top3_ips.txt" ]
    
    actual=$(awk 'NF {gsub(/^[[:space:]]+/, ""); print $1 "\t" $2}' "${WORK}/t5_top3_ips.txt")
    if [[ -f "${WORK}/.expected_top3_ips" ]]; then
        expected=$(cat "${WORK}/.expected_top3_ips")
        [ "$actual" = "$expected" ]
    fi
}

@test "Ticket 5: t5_total_5xx in answers.txt accurately counts all 5xx HTTP responses" {
    [ -f "${WORK}/answers.txt" ]
    got=$(get_answer "t5_total_5xx")
    [ -n "$got" ]
    
    if [[ -f "${WORK}/.expected_5xx" ]]; then
        expected=$(cat "${WORK}/.expected_5xx")
        [ "$got" -eq "$expected" ]
    fi
}

# ==============================================================================
# --- Ticket 6: Evidence Bundle ---
# ==============================================================================

@test "Ticket 6: evidence.tar.gz exists and is a valid gzip tarball" {
    [ -f "${WORK}/evidence.tar.gz" ]
    tar -ztf "${WORK}/evidence.tar.gz" >/dev/null
}

@test "Ticket 6: evidence.tar.gz contains relative findings files" {
    [ -f "${WORK}/evidence.tar.gz" ]
    entries=$(tar -ztf "${WORK}/evidence.tar.gz")
    
    # Assert no entry begins with /
    ! echo "$entries" | grep -E '^/'
    
    echo "$entries" | grep -E '(^|/)t3_rogue_file\.txt$'
    echo "$entries" | grep -E '(^|/)t5_top3_ips\.txt$'
    echo "$entries" | grep -E '(^|/)answers\.txt$'
}
