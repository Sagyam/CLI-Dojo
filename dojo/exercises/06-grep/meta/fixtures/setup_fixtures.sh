#!/usr/bin/env bash
# Generator / setup for hidden fixtures of 06-grep
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES_DIR="${SCRIPT_DIR}"

mkdir -p "${FIXTURES_DIR}/dir_first" \
         "${FIXTURES_DIR}/dir_none" \
         "${FIXTURES_DIR}/dir_multi/sub1" \
         "${FIXTURES_DIR}/dir_multi/sub2" \
         "${FIXTURES_DIR}/dir_multi/sub3"

# 1. dir_first
cat > "${FIXTURES_DIR}/dir_first/node_001.conf" << 'EOF'
# Config
nameserver 1.1.1.1
EOF
cat > "${FIXTURES_DIR}/dir_first/node_002.conf" << 'EOF'
# Config
nameserver 10.10.0.53
EOF

# 2. dir_none
cat > "${FIXTURES_DIR}/dir_none/node_001.conf" << 'EOF'
# Config
nameserver 10.10.0.53
EOF

# 3. dir_multi
cat > "${FIXTURES_DIR}/dir_multi/sub1/a.conf" << 'EOF'
nameserver 8.8.8.8
EOF
cat > "${FIXTURES_DIR}/dir_multi/sub2/b.conf" << 'EOF'
nameserver 9.9.9.9
EOF
cat > "${FIXTURES_DIR}/dir_multi/sub3/c.conf" << 'EOF'
nameserver 10.10.0.53
EOF
