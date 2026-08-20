#!/usr/bin/env bash
# Alternative solution for 07-pipes (using &> and explicit 1> redirections)
set -euo pipefail

WORK="/home/student/dojo/07-pipes"
cd "$WORK"

./noisy-backup.sh 1> out.log 2> err.log || true
./noisy-backup.sh &> combined.log || true
./noisy-backup.sh 2>/dev/null | tee seen.log > archive.log || true

set +e
./noisy-backup.sh >/dev/null 2>&1
EC=$?
set -e

printf "q1_script_exit_code: %d\n" "$EC" > answers.txt

# shellcheck disable=SC2069
./noisy-backup.sh 2>&1 > wrong.log || true
./noisy-backup.sh &> right.log || true

cat > redirect.sh << 'EOF'
#!/usr/bin/env bash
eval "$@" 1> clean.out 2> clean.err
EOF
chmod +x redirect.sh
