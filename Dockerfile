# Use this when Railway Root Directory is EMPTY (build from repo root).
# Copies only the website folder and runs it.
FROM python:3.11-slim

WORKDIR /app
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

COPY laptop_sync_server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY laptop_sync_server/server.py .

EXPOSE 8080
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:$PORT --workers 1 --timeout 120 server:app"]
