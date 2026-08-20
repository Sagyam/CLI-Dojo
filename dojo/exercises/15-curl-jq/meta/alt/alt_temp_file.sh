#!/usr/bin/env bash
set -euo pipefail

WORK="${WORK:-/home/student/dojo/15-curl-jq}"
cd "$WORK"

PORT=$(cat API_PORT)

# 1. Fetch health.json via curl with -o
curl -s -o health.json "http://127.0.0.1:${PORT}/health"

# 2. Status codes using python / curl headers
UNAUTH_CODE=$(curl -s -i -X POST "http://127.0.0.1:${PORT}/notes" | head -n 1 | awk '{print $2}')
AUTH_CODE=$(curl -s -i -X POST -H "X-Auth: chiya" "http://127.0.0.1:${PORT}/notes" | head -n 1 | awk '{print $2}')

sed -i "s/^q1_post_status_unauth:.*/q1_post_status_unauth: ${UNAUTH_CODE}/" answers.txt
sed -i "s/^q2_post_status_auth:.*/q2_post_status_auth: ${AUTH_CODE}/" answers.txt

# 3. Save customers JSON to temporary file and run jq
TMP_CUSTOMERS=$(mktemp /tmp/customers.XXXXXX.json)
curl -s "http://127.0.0.1:${PORT}/customers" > "$TMP_CUSTOMERS"

jq -r 'map(.name) | .[]' "$TMP_CUSTOMERS" > names.txt
jq -r 'map(select(.plan == "premium") | .id) | .[]' "$TMP_CUSTOMERS" > premium.txt
COUNT=$(jq 'length' "$TMP_CUSTOMERS")
sed -i "s/^q3_customer_count:.*/q3_customer_count: ${COUNT}/" answers.txt

rm -f "$TMP_CUSTOMERS"
