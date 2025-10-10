FROM python:3.10-slim

WORKDIR /app

#COPY requirements.txt .  # Optional if you have dependencies
RUN pip install --no-cache-dir redis

# app.py will be mounted from host via docker-compose volume
CMD ["python", "app.py"]
