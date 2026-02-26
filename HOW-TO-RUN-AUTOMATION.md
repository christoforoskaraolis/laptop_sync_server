# How to run the automated tests

## Prerequisites

- **Node.js** (LTS) – [Download](https://nodejs.org) and install. Ensure `node` is in your PATH.

## Option 1: One command from project root (recommended)

Open **PowerShell** in the project folder (where `run-automation.ps1` is) and run:

```powershell
.\run-automation.ps1
```

- **First run:** The script installs dependencies and Chromium, then runs all tests.
- **Smoke tests only:** `.\run-automation.ps1 -SmokeOnly`
- **See the browser while tests run:** `.\run-automation.ps1 -Headed` (opens **one** Chrome window; login uses **admin** / **admin4**)

## Option 2: From the e2e folder

```powershell
cd e2e
npm install
npx playwright install chromium
npm test
```

- Smoke only: `npm run test:smoke`
- P0 only: `npm run test:p0`
- P1 only: `npm run test:p1`
- View last report: `npm run report`

## Configuration (optional)

Tests use your **QA URL** and credentials. Defaults:

- **BASE_URL:** `https://ilrnafvgqa01/fv-web-app/`
- **USERNAME:** `admin`
- **PASSWORD:** `admin4`

To change them:

1. In the **e2e** folder, copy `.env.example` to `.env`.
2. Edit `.env` and set `BASE_URL`, `USERNAME`, `PASSWORD` as needed.

## View results

After a run, open the HTML report:

- **From project root:** `e2e\playwright-report\index.html` (double-click or open in browser)
- **From e2e folder:** run `npm run report`

JSON results are saved to `e2e/playwright-report/results.json`.

## Troubleshooting

| Issue | What to do |
|-------|------------|
| `Node.js is required` | Install Node.js from nodejs.org and restart the terminal. |
| `e2e folder not found` | Run the script from the **project root** (where `run-automation.ps1` is). |
| Tests fail (timeout / not found) | Check that your QA app is running and reachable at `BASE_URL`. Load test data in the DB if needed. |
| Execution policy error (PowerShell) | Run `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned` once, then run the script again. |
| Multiple Chrome windows when using -Headed | Use `.\run-automation.ps1 -Headed` (the script uses one worker so only one browser opens). |
