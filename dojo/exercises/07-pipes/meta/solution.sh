#!/usr/bin/env bash
# Canonical reference solution for 07-pipes
set -euo pipefail

WORK="/home/student/dojo/07-pipes"
cd "$WORK"

./noisy-backup.sh > out.log 2> err.log || true
./noisy-backup.sh > combined.log 2>&1 || true
./noisy-backup.sh 2>/dev/null | tee seen.log archive.log >/dev/null || true

set +e
./noisy-backup.sh >/dev/null 2>&1
EC=$?
set -e

sed -i "s/^q1_script_exit_code:.*/q1_script_exit_code: ${EC}/" answers.txt

# shellcheck disable=SC2069
./noisy-backup.sh 2>&1 > wrong.log || true
./noisy-backup.sh > right.log 2>&1 || true

cat > redirect.sh << 'EOF'
#!/usr/bin/env bash
"$@" > clean.out 2> clean.err
EOF
chmod +x redirect.sh
