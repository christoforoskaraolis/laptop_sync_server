# Rally Marshal Timer – Sync server

This server receives times from the app and shows them in a browser. **Deploy it to the cloud** so marshals (phone in the mountains) and Rally HQ (laptop) can sync over the internet—no need to be on the same network.

---

## Option A: Cloud deployment (recommended – phone in mountains, laptop at HQ)

1. **Deploy the server** to a free host so it has a public HTTPS URL:
   - **[Railway](https://railway.app)** (free tier):
     - Sign up, New Project → Deploy from GitHub (or upload this folder).
     - Root directory: `laptop_sync_server` (or where `server.py` and `requirements.txt` are).
     - Start command: `python server.py` (or leave empty if they detect Python).
     - Add `gunicorn` to `requirements.txt` (see below) and set start command: `gunicorn -b 0.0.0.0:$PORT server:app`.
     - Railway gives you a URL like `https://your-app.up.railway.app`.
   - **[Render](https://render.com)** (free tier):
     - New → Web Service → connect repo, set root to `laptop_sync_server`.
     - Build: `pip install -r requirements.txt`
     - Start: `gunicorn -b 0.0.0.0:$PORT server:app`
     - You get a URL like `https://your-app.onrender.com`.

2. **Phone (marshals)**: In the app, tap the **gear icon** → enter the **exact URL** from step 1 (e.g. `https://your-app.up.railway.app`). Save.

3. **Laptop (HQ)**: Open that **same URL** in a browser. The page lists all recorded times, newest first, and refreshes every 3 seconds.

Phone and laptop only need internet; they do **not** need to be on the same Wi‑Fi.

---

## Option B: Run locally (same network only)

If you only need sync on one site (e.g. same Wi‑Fi):

1. Install Python 3, then:
   ```bash
   pip install -r requirements.txt
   python server.py
   ```
2. Find your laptop’s IP (e.g. `ipconfig` on Windows). On the phone app, set sync URL to `http://YOUR_IP:8765`.
3. On the laptop browser open **http://localhost:8765**.

---

## Usage

- When a marshal taps **Record car** in the app, the time and car number are sent to this server.
- The browser page (same URL as the sync server) shows all entries, newest first; it refreshes every 3 seconds.

Entries are stored in memory only; restarting (or redeploying) the server clears them. For permanent storage you’d add a database later.
