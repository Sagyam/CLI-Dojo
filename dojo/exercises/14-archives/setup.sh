#!/usr/bin/env bash
# Setup for 14-archives (Restore From the Vault)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/14-archives}"
mkdir -p "$WORK"
cd "$WORK"

# Clean any existing artifacts
rm -rf etc vault contents.txt backup-today.tar.zst answers.txt .good_radius_sha256 .vault_tar_name

mkdir -p vault etc/radius etc/dhcp etc/bind

# 1. Generate clean configurations
CLIENT_IP="10.10.$(seeded_int 1 254).$(seeded_int 1 254)"
SECRET="yeti-$(seeded_word)-$(seeded_hex 6)"

cat > etc/radius/radius.conf << EOF
# FreeRADIUS client configuration — YetiLink AAA
client yetilink-nas-01 {
    ipaddr = ${CLIENT_IP}
    secret = ${SECRET}
    require_message_authenticator = yes
    nastype = other
}
EOF

cat > etc/dhcp/dhcpd.conf << EOF
# ISC DHCP Server Configuration
subnet 10.10.0.0 netmask 255.255.0.0 {
    range 10.10.10.100 10.10.10.200;
    option routers 10.10.0.1;
    option domain-name-servers 10.10.0.2;
}
EOF

cat > etc/bind/named.conf << EOF
// BIND9 Configuration
zone "yetilink.internal" {
    type master;
    file "/etc/bind/db.yetilink";
};
EOF

cat > etc/hosts.allow << EOF
# Allowed subnets
ALL: 10.10.0.0/16
EOF

# Calculate good SHA256 before corrupting
GOOD_SHA=$(sha256sum etc/radius/radius.conf | awk '{print $1}')
echo "$GOOD_SHA" > .good_radius_sha256

# 2. Package into vault tarball
DAY=$(printf "%02d" "$(seeded_int 10 28)")
VAULT_DATE="202608${DAY}"
VAULT_TAR="vault/backup-${VAULT_DATE}.tar.gz"
echo "$VAULT_TAR" > .vault_tar_name

tar -czf "$VAULT_TAR" etc/

# 3. Corrupt live radius.conf and add log clutter
cat > etc/radius/radius.conf << 'EOF'
# CORRUPTED CONFIGURATION - FAT FINGER ERROR
client !!!INVALID_SYNTAX {
    secret = BAD_SECRET_ERROR_AAA_DOWN
EOF

cat > etc/radius/radius.log << EOF
$(date -u +"%Y-%m-%d %H:%M:%S") [auth] Access-Reject for user 'prakash' from 10.10.1.5
$(date -u +"%Y-%m-%d %H:%M:%S") [auth] Error reading config file: syntax error near !!!INVALID
EOF

cat > etc/dhcp/dhcpd.log << EOF
DHCPDISCOVER from 52:54:00:12:34:56 via eth0
DHCPOFFER on 10.10.10.150 to 52:54:00:12:34:56 via eth0
EOF

cat > etc/bind/query.log << EOF
client @0x7f88 10.10.1.20#53211 (gateway.yetilink.internal): query: gateway.yetilink.internal IN A + (10.10.0.2)
EOF

# 4. Create answer template
cat > answers.txt << 'EOF'
# YetiLink ticket 14 — answer sheet. Fill values after each colon.
q1_radius_sha256: 
EOF
