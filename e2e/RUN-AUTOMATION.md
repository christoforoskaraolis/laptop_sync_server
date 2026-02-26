# Run automated scenarios (this machine)

The test plan scenarios are automated with **Playwright** in this folder. Run them on your machine (no cloud; no external test runner).

## One-time setup

1. **Install Node.js** (LTS) from [nodejs.org](https://nodejs.org) if you don’t have it.
2. **Configure QA URL and credentials** (optional):
   - Copy `e2e/.env.example` to `e2e/.env`
   - Set `BASE_URL` to your QA app (e.g. `https://ilrnafvgqa01/fv-web-app/`)
   - Set `USERNAME` and `PASSWORD` if different from admin/admin4

## Run from project root

**PowerShell (Windows):**
```powershell
.\run-automation.ps1
```

- Smoke only: `.\run-automation.ps1 -SmokeOnly`
- Show browser: `.\run-automation.ps1 -Headed`

## Run from e2e folder

```bash
cd e2e
npm install
npx playwright install chromium
npm test
```

- Smoke only: `npm run test:smoke`
- P0 only: `npm run test:p0`
- P1 only: `npm run test:p1`
- View last report: `npm run report`

## What runs (mapped to test plan)

| Test plan ID | Automated test |
|--------------|----------------|
| S1, S2, S3   | Smoke: app loads, login page, admin login |
| P0-1         | Admin login end-to-end |
| P0-2         | Back to Home → Cases → Public → open case → Back to Private |
| P1-1, P1-2   | Invalid login, empty credentials |
| P1-3         | Home navigation |
| P1-4, P1-5   | Public Cases loads, Back to Private Cases |
| P1-6         | Open a case from list |
| P1-7         | Page refresh after login |
| P1-8         | User menu opens and shows username |
| P1-11        | Private Cases menu item loads list |
| P1-12        | Back from case detail to list |

Results are in **e2e/playwright-report/** (HTML and results.json). Run this after you’ve loaded test data in QA so Cases and navigation have data.
