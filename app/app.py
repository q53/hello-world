import time
import random

from flask import Flask
from prometheus_flask_exporter import PrometheusMetrics


app = Flask(__name__)
PrometheusMetrics(app)


endpoints = ("", "-/healthy", "-/ready")


@app.route("/")
def hello_world():
    return "Hello, world!",200


@app.route("/-/healthy")
def healthy():
    return "ok",200


@app.route("/-/ready")
def ready():
    return "We are ready", 200


if __name__ == "__main__":
    app.run("0.0.0.0", 5000, threaded=True)
