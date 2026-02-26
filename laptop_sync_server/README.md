# Rally Controls Live Times – Sync server

This server receives times from the Rally Control Timer app and shows them in a browser. Deploy to the cloud so marshals (phone) and HQ (laptop) can sync over the internet.

---

## Deploy to Railway

1. In Railway: **New Project** → **Deploy from GitHub** → select this repo.
2. In the service **Settings**, set **Root Directory** to `laptop_sync_server`.
3. Railway will use the Dockerfile to build and run. You get a URL like `https://your-app.up.railway.app`.

## Deploy to Render

1. **New** → **Web Service** → connect repo, set **Root Directory** to `laptop_sync_server`.
2. Build: `pip install -r requirements.txt`
3. Start: `gunicorn -b 0.0.0.0:$PORT server:app`

---

## Run locally

```bash
pip install -r requirements.txt
python server.py
```

Then open http://localhost:8765. On the phone app, set sync URL to `http://YOUR_IP:8765`.

---

## Usage

- **App**: In Settings, set the sync server URL to your deployed URL (e.g. `https://your-app.up.railway.app`). When you record a time, it is sent to this server.
- **Browser**: Open the same URL to see all entries, grouped by TC, auto-refreshing every 3 seconds. Use **Reset all times** to clear the server list (with confirmation).

Entries are stored in memory only; restarting or redeploying clears them.
