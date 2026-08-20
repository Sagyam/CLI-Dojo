#!/usr/bin/env python3
"""
YetiLink Internal Billing API Server — Exercise 15
Pure Python standard library HTTP server.
"""
import sys
import json
import random
from http.server import HTTPServer, BaseHTTPRequestHandler

NAMES = [
    "Namaste Internet Patan", "Boudha Cyber Hub", "Himalayan ISP Services",
    "Pokhara Valley Broadband", "Kathmandu Fiber Net", "Lalitpur Cloud Ops",
    "Thamel WiFi Zone", "Everest Wireless Links", "Annapurna Digital Core",
    "Mustang Telecom Node", "Bhaktapur Data Center", "Chitwan Cable Network"
]

PLANS = ["basic", "premium", "enterprise", "premium", "basic", "premium"]

def generate_customers(seed):
    rng = random.Random(seed)
    count = rng.randint(8, 12)
    sample_names = rng.sample(NAMES, min(count, len(NAMES)))
    customers = []
    for i, name in enumerate(sample_names, start=1):
        plan = rng.choice(PLANS)
        balance = rng.randint(1200, 48000)
        customers.append({
            "id": f"cust-{i:02d}",
            "name": name,
            "plan": plan,
            "balance": balance,
            "status": "active"
        })
    return customers

class BillingHandler(BaseHTTPRequestHandler):
    customers = []

    def log_message(self, format, *args):
        # Quiet server logging
        return

    def send_json(self, status_code, payload):
        data = json.dumps(payload, indent=2).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        path = self.path.split("?")[0].rstrip("/")
        if path == "/health":
            self.send_json(200, {
                "status": "ok",
                "service": "yetilink-billing-api",
                "version": "1.4.2",
                "environment": "production",
                "customers_count": len(self.customers)
            })
        elif path == "/customers":
            self.send_json(200, self.customers)
        elif path.startswith("/customers/"):
            cust_id = path.split("/customers/")[1]
            found = next((c for c in self.customers if c["id"] == cust_id), None)
            if found:
                self.send_json(200, found)
            else:
                self.send_json(404, {"error": "not found", "id": cust_id})
        else:
            self.send_json(404, {"error": "endpoint not found"})

    def do_POST(self):
        path = self.path.split("?")[0].rstrip("/")
        if path == "/notes":
            auth = self.headers.get("X-Auth")
            if auth == "chiya":
                self.send_json(201, {
                    "status": "created",
                    "message": "Note recorded successfully",
                    "author": "student"
                })
            else:
                self.send_json(401, {
                    "error": "unauthorized",
                    "message": "Missing or invalid X-Auth header"
                })
        else:
            self.send_json(404, {"error": "endpoint not found"})

def run():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8888
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 42
    BillingHandler.customers = generate_customers(seed)
    server = HTTPServer(("127.0.0.1", port), BillingHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()

if __name__ == "__main__":
    run()
