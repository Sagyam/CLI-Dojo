#!/usr/bin/env bash
# Alternative solution for 06-grep (using awk and ripgrep/sed)
set -euo pipefail

WORK="/home/student/dojo/06-grep"
cd "$WORK"

ROGUE_FILE=$(find configs -name "*.conf" -exec awk '/nameserver/ && !/10\.10\.0\.53/ {print FILENAME}' {} + | head -n1)
ROGUE_IP=$(awk '/nameserver/ && !/10\.10\.0\.53/ {print $2}' "$ROGUE_FILE")

FAILED_COUNT=$(awk '/Failed password/ {c++} END {print c}' auth.log)
UNIQUE_IPS=$(awk '/Failed password/ {for(i=1;i<=NF;i++) if($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) ips[$i]=1} END {print length(ips)}' auth.log)

cat > answers.txt << EOF
# YetiLink ticket 06 — answer sheet. Fill values after each colon.
q1_rogue_file_path: ${ROGUE_FILE}
q2_rogue_ip: ${ROGUE_IP}
q3_failed_login_lines: ${FAILED_COUNT}
q4_unique_failing_ips: ${UNIQUE_IPS}
EOF

grep -A 2 -B 2 "nameserver" "$ROGUE_FILE" > context.txt

cat > solution.sh << 'EOF'
#!/usr/bin/env bash
target="${1:-.}"
find "$target" -type f -name "*.conf" -exec awk '/nameserver/ && !/10\.10\.0\.53/ {print FILENAME}' {} + 2>/dev/null
EOF
chmod +x solution.sh
