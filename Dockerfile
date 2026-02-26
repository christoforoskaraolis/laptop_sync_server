# Website only: build from repo root so Railway finds this Dockerfile.
# In Railway: leave Root Directory EMPTY so build runs from repo root.
FROM python:3.11-slim

WORKDIR /app

COPY laptop_sync_server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY laptop_sync_server/server.py .
COPY laptop_sync_server/Procfile .

ENV PORT=5000
EXPOSE 5000

CMD gunicorn --bind 0.0.0.0:${PORT} server:app
