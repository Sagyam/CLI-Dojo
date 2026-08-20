#!/usr/bin/env bash
# Setup for 11-sed (The Datacenter Move)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../../lib" && pwd)"
# shellcheck source=/dev/null
source "${LIB_DIR}/seed.sh"

seed_init "${SEED:-}"

WORK="${WORK:-/home/student/dojo/11-sed}"
mkdir -p "${WORK}/configs"

# Generate 60 config files and nginx.conf
python3 -c "
import os, random
random.seed(${SEED})

work_dir = '${WORK}'
configs_dir = os.path.join(work_dir, 'configs')
os.makedirs(configs_dir, exist_ok=True)

# Clean up any prior .bak files or existing files
for f in os.listdir(configs_dir):
    os.remove(os.path.join(configs_dir, f))

# 1. Generate 60 node configs
for i in range(1, 61):
    conf_path = os.path.join(configs_dir, f'node_{i:02d}.conf')
    lines = [
        f'# YetiLink Node Config {i:02d}',
        f'node_id = node-{i:02d}',
        'datacenter = south-asia-1',
        f'listen_port = {8000 + i}',
        'max_connections = 1024',
    ]

    # Insert old hostname in all configs (1-3 times)
    lines.append('primary_gateway = blr1.yetilink.internal')
    if i % 3 == 0:
        lines.append('sync_target = blr1.yetilink.internal:9000')

    # Insert decoy near-miss hostnames in ~15 configs
    if i % 4 == 0:
        lines.append('fallback_mirror = blr1.yetilink.internal_backup')
    if i % 7 == 0:
        lines.append('cluster_peer = node_blr1.yetilink.internal')

    # Insert deprecated directive in ~30 configs
    if i % 2 == 0:
        lines.append('use_flannel = yes')
    if i % 5 == 0:
        lines.append('use_flannel = no')

    lines.append('healthcheck_interval = 10s')
    lines.append('status = active')

    with open(conf_path, 'w') as f:
        f.write('\n'.join(lines) + '\n')

# 2. Generate nginx.conf (~35 lines)
nginx_lines = [
    'user www-data;',
    'worker_processes auto;',
    'pid /run/nginx.pid;',
    'include /etc/nginx/modules-enabled/*.conf;',
    '',
    'load_module modules/ngx_http_geoip_module.so;',
    'load_module modules/ngx_deprecated_module.so;',
    'load_module modules/ngx_http_image_filter_module.so;',
    '',
    'events {',
    '    worker_connections 768;',
    '    multi_accept on;',
    '}',
    '',
    'http {',
    '    sendfile on;',
    '    tcp_nopush on;',
    '    types_hash_max_size 2048;',
    '    include /etc/nginx/mime.types;',
    '    default_type application/octet-stream;',
    '',
    '    # Security headers',
    '    add_header X-Frame-Options SAMEORIGIN;',
    '    add_header X-Content-Type-Options nosniff;',
    '',
    '    server {',
    '        listen 80 default_server;',
    '        listen [::]:80 default_server;',
    '        root /var/www/html;',
    '        index index.html index.htm;',
    '        server_name _;',
    '',
    '        location / {',
    '            try_files \$uri \$uri/ =404;',
    '        }',
    '',
    '        # Legacy handler',
    '        include /etc/nginx/deprecated_module_routing.conf;',
    '    }',
    '}'
]

with open(os.path.join(work_dir, 'nginx.conf'), 'w') as f:
    f.write('\n'.join(nginx_lines) + '\n')
"
