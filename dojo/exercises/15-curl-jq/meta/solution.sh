#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/15-curl-jq}"
cd "$WORK"

PORT=$(cat API_PORT)

# 1. Fetch health.json
curl -s "http://127.0.0.1:${PORT}/health" > health.json

# 2. Check HTTP status codes
UNAUTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "http://127.0.0.1:${PORT}/notes")
AUTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "X-Auth: chiya" "http://127.0.0.1:${PORT}/notes")

sed -i "s/^q1_post_status_unauth:.*/q1_post_status_unauth: ${UNAUTH_CODE}/" answers.txt
sed -i "s/^q2_post_status_auth:.*/q2_post_status_auth: ${AUTH_CODE}/" answers.txt

# 3. Customer names to names.txt
curl -s "http://127.0.0.1:${PORT}/customers" | jq -r '.[].name' > names.txt

# 4. Premium IDs to premium.txt
curl -s "http://127.0.0.1:${PORT}/customers" | jq -r '.[] | select(.plan == "premium") | .id' > premium.txt

# 5. Customer count to answers.txt
COUNT=$(curl -s "http://127.0.0.1:${PORT}/customers" | jq 'length')
sed -i "s/^q3_customer_count:.*/q3_customer_count: ${COUNT}/" answers.txt
