# Website only: build from repo root so Railway finds this Dockerfile.
# In Railway: leave Root Directory EMPTY so build runs from repo root.
FROM python:3.11-slim

WORKDIR /app

# So logs show immediately in Railway
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

COPY laptop_sync_server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY laptop_sync_server/server.py .

EXPOSE 8080

# Railway sets PORT at runtime (e.g. 8080); use shell so it's expanded
CMD sh -c 'exec gunicorn --bind 0.0.0.0:${PORT:-8080} --workers 1 --timeout 120 server:app'
