# Website only: build from repo root so Railway finds this Dockerfile.
# In Railway: leave Root Directory EMPTY so build runs from repo root.
FROM python:3.11-slim

WORKDIR /app

# So logs show immediately in Railway
ENV PYTHONUNBUFFERED=1
ENV PORT=5000

COPY laptop_sync_server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY laptop_sync_server/server.py .

EXPOSE 5000

# Railway sets PORT at runtime; use shell so it's expanded
CMD sh -c 'exec gunicorn --bind 0.0.0.0:${PORT:-5000} --workers 1 --timeout 120 server:app'
