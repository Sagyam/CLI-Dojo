# 🎫 Ticket 15 — Talking to the Customer API
> **From:** Anita · **Priority:** P2 · **Queue:** Tier 4 — DevOps Flavor

The internal customer billing API service is up, but web dashboards are unavailable during maintenance. Anita needs you to verify API health, test endpoint authentication, and extract customer records directly from the CLI using `curl` and `jq`.

The local API server is listening on `127.0.0.1`. The active port number is written in `API_PORT`.

## Your tasks
In `~/dojo/15-curl-jq/`:
1. Query `GET http://127.0.0.1:<PORT>/health` and save the JSON response body to `health.json`.
2. Interrogate `POST http://127.0.0.1:<PORT>/notes`:
   - Send a request *without* authentication headers and record the HTTP status code (e.g. `401`) in `answers.txt` (`q1_post_status_unauth`).
   - Send a request *with* the header `X-Auth: chiya` (e.g. `-H "X-Auth: chiya"`) and record the HTTP status code (e.g. `201`) in `answers.txt` (`q2_post_status_auth`).
3. Query `GET http://127.0.0.1:<PORT>/customers` and extract all customer names as raw text (one per line, without JSON quotes) to `names.txt` using `jq -r`.
4. From the same `/customers` endpoint, extract the `id` of every customer on the `"premium"` plan (`plan == "premium"`) and save to `premium.txt` (one per line, raw text).
5. Count the total number of customers in the `/customers` array using `jq length` and record the number in `answers.txt` (`q3_customer_count`).

## Success criteria
Run `dojo check 15`. All rubric checks pass:
- `health.json` is valid JSON and contains the healthy service status.
- `answers.txt` records the unauthorized (401) and authorized (201) status codes.
- `names.txt` contains all customer names (raw strings, one per line).
- `premium.txt` contains only the IDs of customers with `plan == "premium"`.
- `answers.txt` contains the correct customer count.

## Stuck?
`dojo hint 15` — three progressive hints.

## 💼 Interview angle
Modern DevOps engineers interact with REST APIs, cloud control planes (AWS, Kubernetes API), and observability tools via `curl` and `jq` constantly. Knowing how to capture HTTP status codes (`-w '%{http_code}'`), set custom headers (`-H`), and filter nested JSON arrays with `jq` filters (`select`, `map`, `-r`) is a required operational skill.

<details><summary>🔓 Full solution (spoilers — try hints first)</summary>

```bash
cd ~/dojo/15-curl-jq

PORT=$(cat API_PORT)

# 1. Fetch /health to health.json
curl -s "http://127.0.0.1:${PORT}/health" > health.json

# 2. Check HTTP status codes
UNAUTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "http://127.0.0.1:${PORT}/notes")
AUTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "X-Auth: chiya" "http://127.0.0.1:${PORT}/notes")

sed -i "s/^q1_post_status_unauth:.*/q1_post_status_unauth: ${UNAUTH_CODE}/" answers.txt
sed -i "s/^q2_post_status_auth:.*/q2_post_status_auth: ${AUTH_CODE}/" answers.txt

# 3. Customer names to names.txt
curl -s "http://127.0.0.1:${PORT}/customers" | jq -r '.[].name' > names.txt

# 4. Premium customer IDs to premium.txt
curl -s "http://127.0.0.1:${PORT}/customers" | jq -r '.[] | select(.plan == "premium") | .id' > premium.txt

# 5. Customer count to answers.txt
COUNT=$(curl -s "http://127.0.0.1:${PORT}/customers" | jq 'length')
sed -i "s/^q3_customer_count:.*/q3_customer_count: ${COUNT}/" answers.txt

# 6. Verify
dojo check 15
```
</details>
