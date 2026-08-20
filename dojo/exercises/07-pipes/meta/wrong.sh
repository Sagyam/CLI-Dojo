#!/usr/bin/env bash
# Deliberately incorrect attempt for 07-pipes
set -euo pipefail

WORK="/home/student/dojo/07-pipes"
cd "$WORK"

# Swaps out.log and err.log
./noisy-backup.sh > err.log 2> out.log || true
echo "wrong" > combined.log
echo "wrong" > seen.log
echo "wrong2" > archive.log
echo "wrong" > wrong.log
echo "wrong" > right.log

printf "q1_script_exit_code: 0\n" > answers.txt

cat > redirect.sh << 'EOF'
#!/usr/bin/env bash
echo "broken"
EOF
chmod +x redirect.sh
