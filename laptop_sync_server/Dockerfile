# Build and run from this folder. In Railway: set Root Directory = laptop_sync_server
FROM python:3.11-slim

WORKDIR /app
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY server.py .

# Railway sets PORT (e.g. 8080). Default 8080 if not set.
ENV PORT=8080
EXPOSE 8080
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:$PORT --workers 1 --timeout 120 server:app"]
