from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import math
import os
import time

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "app_requests_total",
    "Total number of HTTP requests",
    ["method", "endpoint", "status"]
)

REQUEST_LATENCY = Histogram(
    "app_request_duration_seconds",
    "HTTP request latency",
    ["endpoint"]
)

@app.route("/")
def home():
    start = time.time()
    response = {
        "message": "Application is running",
        "environment": os.getenv("ENV", "dev")
    }
    REQUEST_COUNT.labels("GET", "/", "200").inc()
    REQUEST_LATENCY.labels("/").observe(time.time() - start)
    return jsonify(response), 200

@app.route("/health")
def health():
    REQUEST_COUNT.labels("GET", "/health", "200").inc()
    return jsonify({"status": "ok"}), 200

@app.route("/slow")
def slow():
    start = time.time()
    delay = float(request.args.get("seconds", 5))
    time.sleep(delay)
    REQUEST_COUNT.labels("GET", "/slow", "200").inc()
    REQUEST_LATENCY.labels("/slow").observe(time.time() - start)
    return jsonify({"message": f"Response delayed by {delay} seconds"}), 200

@app.route("/cpu")
def cpu_stress():
    start = time.time()
    duration = int(request.args.get("seconds", 10))
    end_time = time.time() + duration

    while time.time() < end_time:
        for i in range(1, 10000):
            math.sqrt(i) * math.sqrt(i)

    REQUEST_COUNT.labels("GET", "/cpu", "200").inc()
    REQUEST_LATENCY.labels("/cpu").observe(time.time() - start)
    return jsonify({"message": f"CPU stressed for {duration} seconds"}), 200

memory_hog = []

@app.route("/memory")
def memory_stress():
    start = time.time()
    mb = int(request.args.get("mb", 100))
    memory_hog.append("A" * 1024 * 1024 * mb)
    REQUEST_COUNT.labels("GET", "/memory", "200").inc()
    REQUEST_LATENCY.labels("/memory").observe(time.time() - start)
    return jsonify({"message": f"Allocated approximately {mb} MB"}), 200

@app.route("/error")
def error():
    REQUEST_COUNT.labels("GET", "/error", "500").inc()
    return jsonify({"error": "Intentional error for testing"}), 500

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
