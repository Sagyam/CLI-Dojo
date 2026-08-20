#!/usr/bin/env bash
# Deliberately incorrect attempt for 06-grep (hardcodes wrong rogue IP and static echo in solution.sh)
set -euo pipefail

WORK="/home/student/dojo/06-grep"
cd "$WORK"

cat > answers.txt << 'EOF'
# YetiLink ticket 06 — answer sheet. Fill values after each colon.
q1_rogue_file_path: configs/cluster_01/node_001.conf
q2_rogue_ip: 8.8.8.8
q3_failed_login_lines: 0
q4_unique_failing_ips: 0
EOF

echo "nameserver 8.8.8.8" > context.txt

cat > solution.sh << 'EOF'
#!/usr/bin/env bash
# Flawed hardcoded output that fails on hidden fixtures
echo "configs/cluster_01/node_001.conf"
EOF
chmod +x solution.sh
