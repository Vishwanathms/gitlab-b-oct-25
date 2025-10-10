# 🐍 Python + Redis with Docker Compose

This project demonstrates how to run a **Python Flask web application** connected to a **Redis database** using **Docker Compose**.  
The setup allows you to edit the `app.py` file outside the container — and see changes reflected automatically via Flask’s auto-reload.

---

## 📁 Project Structure

```

project-root/
│
├── docker-compose.yml
├── app.py
└── python-app/
├── Dockerfile
└── requirements.txt

````

---

## ⚙️ Components

### **1. Redis Service**
- Uses the official `redis:latest` image.
- Exposes port **6379** for connections.
- Acts as the backend data store.

### **2. Python App Service**
- Built from a custom `Dockerfile` in `python-app/`.
- Runs a Flask web server on port **5000**.
- Connects to Redis using the hostname `redis` (defined in the Compose network).
- Auto-reloads on code changes in `app.py`.

---

## 🧱 docker-compose.yml

```yaml
version: "3.9"

services:
  redis:
    image: redis:latest
    container_name: redis-server
    ports:
      - "6379:6379"

  python-app:
    build:
      context: ./python-app
    container_name: python-app
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - FLASK_ENV=development
      - FLASK_APP=app.py
    volumes:
      - ./app.py:/app/app.py
    depends_on:
      - redis
    ports:
      - "5000:5000"
    command: ["flask", "run", "--host=0.0.0.0"]
````

---

## 🐳 python-app/Dockerfile

```dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

CMD ["flask", "run", "--host=0.0.0.0"]
```

---

## 📦 python-app/requirements.txt

```
flask
redis
```

---

## 🧠 app.py

```python
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
    app.run(host='0.0.0.0', port=5000, debug=True)
```

---

## 🚀 Running the Project

1. **Build and start the containers**

   ```bash
   docker-compose up --build
   ```

2. **Access the app**

   * Open your browser and go to → [http://localhost:5000](http://localhost:5000)
   * You should see something like:

     ```
     Hello! This page has been viewed 1 times.
     ```

3. **Modify your code**

   * Edit `app.py` on your host system.
   * Flask auto-reload will detect the change and restart automatically.

4. **Stop the containers**

   ```bash
   docker-compose down
   ```

---

## 🧩 Environment Variables

| Variable     | Description                          | Default       |
| ------------ | ------------------------------------ | ------------- |
| `REDIS_HOST` | Redis hostname used by Flask app     | `redis`       |
| `REDIS_PORT` | Redis port                           | `6379`        |
| `FLASK_ENV`  | Flask environment (for debug/reload) | `development` |
| `FLASK_APP`  | Main Flask app file                  | `app.py`      |

---

## 🧰 Common Commands

| Action              | Command                             |
| ------------------- | ----------------------------------- |
| Start services      | `docker-compose up`                 |
| Rebuild images      | `docker-compose up --build`         |
| Stop services       | `docker-compose down`               |
| View logs           | `docker-compose logs -f python-app` |
| Access Python shell | `docker exec -it python-app bash`   |

---

## ✅ Expected Output

In your terminal:

```
python-app  |  * Running on http://0.0.0.0:5000
python-app  |  * Restarting with stat
python-app  |  * Debugger is active!
```

In your browser:

```
Hello! This page has been viewed 3 times.
```

---

## 💡 Notes

* The `app.py` file is mounted as a volume, allowing live edits.
* Flask’s auto-reload mode (`FLASK_ENV=development`) restarts the app when code changes.
* Redis data is not persisted — for persistence, mount a volume to `/data` in the Redis container.

---

## 🧹 Cleanup

To remove all containers, images, and volumes created by this project:

```bash
docker-compose down --rmi all -v
```
