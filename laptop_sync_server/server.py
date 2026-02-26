"""
Rally Control Timer – Sync server.

Use over the internet: deploy to a cloud host so marshals (phone) and HQ (laptop)
can sync over the internet.

  Local:  python server.py  →  http://localhost:8765
  Cloud:  Railway/Render    →  https://your-app.up.railway.app
"""

from flask import Flask, request, jsonify
import os

app = Flask(__name__, static_folder=None)


@app.after_request
def add_cors(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    return response


# In-memory list: newest first. Each item: {"time": "...", "carNumber": n, "tc": "TC1"}
entries = []


@app.route("/")
def index():
    return """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Rally Controls Live Times</title>
  <style>
    * { box-sizing: border-box; }
    body {
      font-family: system-ui, sans-serif;
      background: #1a1a1a;
      color: #ffb74d;
      margin: 0;
      padding: 24px;
    }
    h1 { font-size: 1.5rem; margin-bottom: 16px; }
    .entry { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid #333; font-size: 1.25rem; }
    .entry .num-car { color: #ccc; }
    .entry .time { font-variant-numeric: tabular-nums; color: #ffb74d; }
    .empty { color: #666; padding: 24px 0; }
    #list { max-width: 560px; }
    .tc-block { margin-bottom: 24px; }
    .tc-title { font-size: 1.1rem; color: #ffb74d; margin: 0 0 8px 0; padding-bottom: 4px; border-bottom: 1px solid #444; }
  </style>
</head>
<body>
  <h1>Rally Controls Live Times</h1>
  <p>
    <button type="button" id="resetBtn" style="padding:8px 16px;background:#c62828;color:#fff;border:none;border-radius:6px;cursor:pointer;font-size:14px;">Reset all times</button>
  </p>
  <p style="color:#888;font-size:14px;">Auto-refreshing every 3 seconds. Split by TC. Oldest first (normal order).</p>
  <p id="lastUpdate" style="color:#666;font-size:12px;margin-top:-8px;">Last updated: --</p>
  <div id="list">
    <div class="empty">No entries yet. Record a time on the app to see it here.</div>
  </div>
  <script>
    function refresh() {
      fetch('/entries?t=' + Date.now())
        .then(r => r.json())
        .then(data => {
          document.getElementById('lastUpdate').textContent = 'Last updated: ' + new Date().toLocaleTimeString();
          const list = document.getElementById('list');
          if (data.length === 0) {
            list.innerHTML = '<div class="empty">No entries yet. Record a time on the app to see it here.</div>';
            return;
          }
          function formatTcLabel(tcVal) {
            if (tcVal == null || tcVal === '') return '(No TC)';
            var s = String(tcVal).trim();
            if (s.toUpperCase().indexOf('TC') === 0) return s;
            return 'TC' + s;
          }
          var byTc = {};
          data.forEach(function(e) {
            var key = (e.tc != null && e.tc !== '') ? String(e.tc).trim() : '';
            if (!byTc[key]) byTc[key] = [];
            byTc[key].push(e);
          });
          var tcs = Object.keys(byTc).sort();
          list.innerHTML = tcs.map(function(tcKey) {
            var entries = byTc[tcKey].slice().reverse();
            var rows = entries.map(function(e, i) {
              var num = i + 1;
              return '<div class="entry"><span class="num-car">' + num + '. #' + escapeHtml(String(e.carNumber)) + '</span><span class="time">' + escapeHtml(e.time) + '</span></div>';
            }).join('');
            return '<div class="tc-block"><h2 class="tc-title">' + escapeHtml(formatTcLabel(tcKey)) + '</h2>' + rows + '</div>';
          }).join('');
        })
        .catch(function() { document.getElementById('lastUpdate').textContent = 'Last updated: (error)'; });
    }
    function escapeHtml(s) { var d = document.createElement('div'); d.textContent = s; return d.innerHTML; }
    document.getElementById('resetBtn').onclick = function() {
      if (!confirm('Are you sure you want to delete all times?')) return;
      fetch('/reset-entries', { method: 'POST', headers: { 'Content-Type': 'application/json' } })
        .then(function(r) { if (r.ok) refresh(); })
        .catch(function() { alert('Reset failed'); });
    };
    refresh();
    setInterval(refresh, 3000);
  </script>
</body>
</html>
"""


@app.route("/entries")
def get_entries():
    resp = jsonify(entries)
    resp.headers["Cache-Control"] = "no-store, no-cache, must-revalidate"
    resp.headers["Pragma"] = "no-cache"
    return resp


@app.route("/entry", methods=["POST"])
def add_entry():
    data = request.get_json(force=True, silent=True) or {}
    time = data.get("time", "")
    try:
        car_number = int(data.get("carNumber", 0))
    except (TypeError, ValueError):
        car_number = 0
    if not isinstance(time, str):
        time = str(time)
    tc = data.get("tc") or ""
    if not isinstance(tc, str):
        tc = str(tc)
    entries.insert(0, {"time": time, "carNumber": car_number, "tc": tc})
    return jsonify({"ok": True}), 201


@app.route("/reset-entries", methods=["POST"])
def reset_entries():
    global entries
    entries.clear()
    return jsonify({"ok": True}), 200


@app.route("/health")
def health():
    return jsonify({"status": "ok"})


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8765))
    print(f"Rally Control sync server: http://0.0.0.0:{port}")
    app.run(host="0.0.0.0", port=port, debug=False)
