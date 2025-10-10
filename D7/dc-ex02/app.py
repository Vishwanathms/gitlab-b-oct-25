from flask import Flask
import os
import redis

app = Flask(__name__)

redis_host = os.getenv("REDIS_HOST", "localhost")
redis_port = int(os.getenv("REDIS_PORT", 6379))

r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

@app.route('/')
def index():
    r.incr('hits')
    count = r.get('hits')
    return f"Hello! This page has been viewed {count} times."

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)