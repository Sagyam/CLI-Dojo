#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/16-env-path}"
cd "$WORK"

ASSIGNED_ENV=$(cat DEPLOY_ENV.txt)

# 1. Symlink yetideploy into ~/bin
mkdir -p "$HOME/bin"
chmod +x tools/yetideploy
ln -sf "$HOME/dojo/16-env-path/tools/yetideploy" "$HOME/bin/yetideploy"

# 2. Append exports to ~/.zshrc
if ! grep -q "YETI_ENV=" "$HOME/.zshrc"; then
    echo "export YETI_ENV=${ASSIGNED_ENV}" >> "$HOME/.zshrc"
    echo "export YETI_REGION=ap-south-1" >> "$HOME/.zshrc"
fi

# 3. Export for current subshell and run yetideploy
export YETI_ENV="${ASSIGNED_ENV}"
export YETI_REGION="ap-south-1"
"$HOME/bin/yetideploy" > token.txt

# 4. Answers: find first directory in zsh login PATH
FIRST_DIR=$(zsh -ic 'echo $PATH' 2>/dev/null | tail -n 1 | cut -d: -f1)
sed -i "s|^q1_first_path_dir:.*|q1_first_path_dir: ${FIRST_DIR}|" answers.txt
