#!/usr/bin/env bash
# Setup for 16-env-path (The Missing Deploy Tool)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/16-env-path}"
STUDENT_HOME="/home/student"
mkdir -p "$WORK"
cd "$WORK"

# 1. Clean previous run state
rm -rf tools token.txt answers.txt DEPLOY_ENV.txt .expected_token .expected_env
rm -f "${STUDENT_HOME}/bin/yetideploy"

# Clean any previous exports added to .zshrc
if [[ -f "${STUDENT_HOME}/.zshrc" ]]; then
    sed -i '/YETI_ENV/d' "${STUDENT_HOME}/.zshrc"
    sed -i '/YETI_REGION/d' "${STUDENT_HOME}/.zshrc"
    sed -i '/16-env-path/d' "${STUDENT_HOME}/.zshrc"
fi

# 2. Generate seeded values
TOKEN="DEPLOY_TOKEN_$(seeded_hex 16)"
ASSIGNED_ENV="staging-$(seeded_word)"

echo "$TOKEN" > .expected_token
echo "$ASSIGNED_ENV" > .expected_env
echo "$ASSIGNED_ENV" > DEPLOY_ENV.txt

# 3. Create deploy tool
mkdir -p tools
cat > tools/yetideploy << EOF
#!/usr/bin/env bash
set -euo pipefail

if [[ "\${YETI_ENV:-}" != "${ASSIGNED_ENV}" ]]; then
    echo "Error: YETI_ENV must be exported as '${ASSIGNED_ENV}'. Current: '\${YETI_ENV:-}'" >&2
    exit 1
fi

if [[ "\${YETI_REGION:-}" != "ap-south-1" ]]; then
    echo "Error: YETI_REGION must be exported as 'ap-south-1'. Current: '\${YETI_REGION:-}'" >&2
    exit 1
fi

echo "${TOKEN}"
EOF

chmod +x tools/yetideploy

# 4. Answer sheet template
cat > answers.txt << 'EOF'
# YetiLink ticket 16 — answer sheet. Fill values after each colon.
q1_first_path_dir: 
EOF
