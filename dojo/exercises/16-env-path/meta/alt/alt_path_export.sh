#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/16-env-path}"
cd "$WORK"

ASSIGNED_ENV=$(cat DEPLOY_ENV.txt)
chmod +x tools/yetideploy

# Alt method: Export tools directory directly in PATH
if ! grep -q "16-env-path/tools" "$HOME/.zshrc"; then
    {
        echo "export PATH=\"\$PATH:${WORK}/tools\""
        echo "export YETI_ENV=${ASSIGNED_ENV}"
        echo "export YETI_REGION=ap-south-1"
    } >> "$HOME/.zshrc"
fi

export PATH="$PATH:${WORK}/tools"
export YETI_ENV="${ASSIGNED_ENV}"
export YETI_REGION="ap-south-1"

yetideploy > token.txt

FIRST_DIR=$(zsh -ic 'echo $PATH' 2>/dev/null | tail -n 1 | cut -d: -f1)
sed -i "s|^q1_first_path_dir:.*|q1_first_path_dir: ${FIRST_DIR}|" answers.txt
