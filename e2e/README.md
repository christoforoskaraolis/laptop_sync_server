# FV Web App – Regression Tests (Playwright)

Run regression tests **without Ginger**. Uses [Playwright](https://playwright.dev/) so you can add many more tests and run them from the command line or CI.

## Quick start

1. **Install dependencies** (from the `e2e` folder):
   ```bash
   cd e2e
   npm install
   ```

2. **Configure environment** (optional – defaults work for FV QA):
   ```bash
   copy .env.example .env
   # Edit .env: BASE_URL, USERNAME, PASSWORD
   ```

3. **Run all tests**:
   ```bash
   npm test
   ```

4. **Run by level** (same as regression plan):
   ```bash
   npm run test:smoke   # Smoke only (S1–S3)
   npm run test:p0      # P0 critical path
   npm run test:p1      # P1 high priority
   ```

5. **View report after a run**:
   ```bash
   npm run report
   ```

## Test structure

| Folder / file            | Contents |
|--------------------------|----------|
| `tests/smoke.spec.ts`    | S1–S3: app loads, login page, admin login |
| `tests/login.spec.ts`    | P0-1, P1-1, P1-2, P1-7 (login + invalid/empty + refresh) |
| `tests/navigation.spec.ts` | P0-2, P1-3 to P1-6 (Home, Cases, Public/Private, open case) |
| `tests/placeholder-more.spec.ts` | Stubs for P0-3 (logout) and more areas |
| `selectors.ts`           | All FV selectors (one place to update if UI changes) |
| `auth.ts`                | `loginAsAdmin()` helper for tests that need to be logged in |

Tests are tagged: `@smoke`, `@p0`, `@p1`, `@p2`. Use `--grep @smoke` etc. to run a subset.

## Adding more tests

1. **New flows (e.g. another menu or screen)**  
   - Add selectors to `selectors.ts` if needed.  
   - Create a new spec file, e.g. `tests/reports.spec.ts`, or add to `placeholder-more.spec.ts`.  
   - Use `import { loginAsAdmin } from '../auth'` and `import { Selectors } from '../selectors'`.

2. **New selectors**  
   - Inspect the app in the browser (F12) and add XPath or role/name to `selectors.ts`.  
   - In tests use `page.locator(Selectors.yourNewSelector)`.

3. **Run in headed mode** (see the browser):
   ```bash
   npm run test:headed
   ```

4. **Run a single file**:
   ```bash
   npx playwright test tests/login.spec.ts
   ```

5. **Debug**:
   ```bash
   npx playwright test --debug
   ```

## Environment variables

| Variable   | Default (if not set) | Description        |
|-----------|----------------------|--------------------|
| `BASE_URL` | `https://ilrnafvgqa01/fv-web-app/` | FV web app URL (no trailing slash in config) |
| `USERNAME` | `admin`             | Login username     |
| `PASSWORD` | `admin4`            | Login password     |

## CI / pre-release

Run before releasing to customer:

```bash
cd e2e
npm ci
npm run test:smoke && npm run test:p0
```

If both pass, proceed with P1 or full suite. See project root `REGRESSION_TESTING_PLAN.md` for the full plan.
