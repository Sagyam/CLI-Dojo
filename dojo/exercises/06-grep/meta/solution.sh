#!/usr/bin/env bash
# Canonical reference solution for 06-grep
set -euo pipefail

WORK="/home/student/dojo/06-grep"
cd "$WORK"

ROGUE_LINE=$(grep -rn "nameserver" configs/ | grep -v "10.10.0.53" | head -n1)
ROGUE_FILE=$(echo "$ROGUE_LINE" | cut -d: -f1)
ROGUE_IP=$(echo "$ROGUE_LINE" | awk '{print $NF}')

FAILED_COUNT=$(grep -c "Failed password" auth.log)
UNIQUE_IPS=$(grep "Failed password" auth.log | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -u | wc -l)

cat > answers.txt << EOF
# YetiLink ticket 06 — answer sheet. Fill values after each colon.
q1_rogue_file_path: ${ROGUE_FILE}
q2_rogue_ip: ${ROGUE_IP}
q3_failed_login_lines: ${FAILED_COUNT}
q4_unique_failing_ips: ${UNIQUE_IPS}
EOF

grep -C 2 "nameserver" "$ROGUE_FILE" > context.txt

cat > solution.sh << 'EOF'
#!/usr/bin/env bash
target="${1:-.}"
grep -rn "nameserver" "$target" 2>/dev/null | grep -v "10.10.0.53" | cut -d: -f1
EOF
chmod +x solution.sh
