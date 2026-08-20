#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/15-curl-jq}"
cd "$WORK"

PORT=$(cat API_PORT)

# Wrong solution:
# 1. health.json with missing fields
echo '{"status": "error"}' > health.json

# 2. Wrong status codes
sed -i "s/^q1_post_status_unauth:.*/q1_post_status_unauth: 200/" answers.txt
sed -i "s/^q2_post_status_auth:.*/q2_post_status_auth: 500/" answers.txt

# 3. names.txt WITH quotes (missing -r)
curl -s "http://127.0.0.1:${PORT}/customers" | jq '.[].name' > names.txt

# 4. premium.txt WITH quotes
curl -s "http://127.0.0.1:${PORT}/customers" | jq '.[] | select(.plan == "premium") | .id' > premium.txt

sed -i "s/^q3_customer_count:.*/q3_customer_count: 999/" answers.txt
