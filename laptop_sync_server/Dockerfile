# Use Python 3.11
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY server.py .
COPY Procfile .

# Railway provides PORT at runtime
ENV PORT=5000
EXPOSE 5000

# Run with gunicorn (same as Procfile)
CMD gunicorn --bind 0.0.0.0:${PORT} server:app
