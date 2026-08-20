#!/usr/bin/env bash
# YetiLink CLI Dojo — Container Entrypoint
set -euo pipefail

# Initialize student home directory if empty or missing dotfiles
if [[ ! -f /home/student/.zshrc ]]; then
    mkdir -p /home/student
    cp -rT /etc/skel-dojo /home/student 2>/dev/null || true
fi

# Ensure progress directory and file exist
mkdir -p /home/student/.dojo
if [[ ! -f /home/student/.dojo/progress.json ]]; then
    echo '{"exercises":{}}' > /home/student/.dojo/progress.json
fi
chmod 666 /home/student/.dojo/progress.json 2>/dev/null || true

# Fix ownership of student home
chown -R student:student /home/student

# If command arguments were passed, execute them (as current user / root)
if [[ $# -gt 0 ]]; then
    exec "$@"
else
    exec gosu student zsh -l
fi
