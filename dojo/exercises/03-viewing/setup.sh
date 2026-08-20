#!/usr/bin/env bash
# Setup for 03-viewing (The 400 MB Router Log)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/03-viewing}"
mkdir -p "$WORK"

# Deterministic line count between 30,000 and 60,000
TOTAL_LINES=$(seeded_int 35000 55000)
PANIC_LINE=$(seeded_int 12000 32000)
PANIC_HEX=$(seeded_hex 4)
PANIC_IP=$(seeded_ip)
PANIC_TEXT="[PANIC] BGP router fatal exception at peer ${PANIC_IP}: err_code=0x${PANIC_HEX}"

# Fast log generation using gawk
gawk -v total="$TOTAL_LINES" -v panic_l="$PANIC_LINE" -v panic_txt="$PANIC_TEXT" '
BEGIN {
    for (i = 1; i <= total; i++) {
        if (i == panic_l) {
            printf "2026-08-19T03:14:%02dZ [CRIT] core-gw-01 %s\n", (i % 60), panic_txt
        } else {
            printf "2026-08-19T03:14:%02dZ [INFO] core-gw-01 interface eth%d packet rx count=%d status=OK\n", (i % 60), (i % 4), i * 17
        }
    }
}
' > "${WORK}/core-router.log"

cat > "${WORK}/answers.txt" << 'EOF'
# YetiLink ticket 03 — answer sheet. Fill values after each colon.
q1_total_lines: 
q2_panic_line_number: 
EOF
