# Rally Controls Live Times

Web server for the Rally Control Timer app. Shows live times from the app and lets you reset them.

## Deploy on Railway

1. In Railway: **New Project** → **Deploy from GitHub** → choose repo `christoforoskaraolis/laptop_sync_server`.
2. In the new service go to **Settings** → **Source**.
3. Set **Root Directory** to: `laptop_sync_server`
4. Deploy. Railway will use the Dockerfile in this folder.

Your site will be at a URL like `https://xxx.up.railway.app`. Put that URL in the app (Settings → Sync server URL).

## Run locally

```bash
cd laptop_sync_server
pip install -r requirements.txt
python server.py
```

Open http://localhost:8765

## What it does

- **GET /** – Web page: “Rally Controls Live Times”, list of entries by TC, Reset button (with “Are you sure you want to delete all times?”).
- **GET /entries** – JSON list of entries (for the page).
- **POST /entry** – App sends a new time/car/TC here.
- **POST /reset-entries** – Clears all entries (used by the Reset button).
