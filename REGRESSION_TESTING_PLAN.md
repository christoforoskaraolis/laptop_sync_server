# Regression Testing Plan – FV Web Application

This plan is used **before releasing builds to customers** to confirm that critical functionality works as expected. You run it **manually** on your **QA environment**, using data that you load yourself in the database.

---

## 1. Scope and Objectives

| Item | Description |
|------|-------------|
| **Application** | FraudView (FV) Web App |
| **Environment** | **QA only** – the single environment you use for pre-release testing |
| **Base URL (example)** | `https://ilrnafvgqa01/fv-web-app/` (your QA URL) |
| **Purpose** | Pre-release regression: confirm main flows work before customer release |
| **When to run** | After deploying a release candidate to QA and loading test data |
| **How you test** | **Automated** (Playwright): run **`run-automation.ps1`** from project root. **Manual** (browser): **test-plan/test-plan.html**. |

**Success criteria:** All **Smoke** and **P0** checks pass; no open **P0/P1** bugs. Run P1 when you can; P2 when time allows.

---

## 2. Test Environment and Data (QA Only)

- **Environment:** Your **QA environment only**. No separate staging or e2e test env.
- **Browser:** Google Chrome (primary).
- **Test user:** Admin — Username: `admin`, Password: `admin4` (or your QA test account).
- **Data:** You **load test data manually in the database** before running this regression. There is no automated data setup.

### 2.1 Before You Run the Regression

1. **Deploy** the release candidate to QA and note the build/version.
2. **Load test data in the database** (manually, using your usual process), for example:
   - Users/roles needed for login (e.g. admin).
   - Data needed for **Public Cases** and **Private Cases** (e.g. at least one case so you can open a case and use “Back to Private Cases”).
   - Any other data required for the flows you will test (filters, reports, etc.).
3. **Confirm** the app is up and the QA URL is correct.
4. Then **run tests**: (a) **Automated**: from project root run **`.\run-automation.ps1`** (requires Node.js; see **e2e/RUN-AUTOMATION.md**). (b) **Manual**: open **`test-plan/test-plan.html`** in your browser and record Pass/Fail, then **Save report**.

---

## 3. Test Levels Overview

| Level | Purpose | When to run |
|-------|---------|-------------|
| **Smoke** | App loads, login works, main entry points respond. | Every build / deployment. |
| **P0 – Critical path** | Login, navigation, core Cases flow. | Every release candidate. |
| **P1 – High** | Important features and workflows. | Every release; can subset if time-boxed. |
| **P2 – Regression** | Broader coverage, edge cases, non-critical UI. | When time allows or on major releases. |

---

## 4. Smoke Tests (Run First)

Run these first on QA. If any fail, fix before continuing.

| # | Test case | Steps | Expected result | Pass? |
|---|-----------|--------|-----------------|------|
| S1 | Application loads | Open QA FV URL in Chrome. | Page loads; no critical errors. | ☐ |
| S2 | Login page visible | From S1, observe screen. | Sign In screen with username/password and Sign In button. | ☐ |
| S3 | Admin login success | Enter admin credentials, click Sign In. | User is logged in (e.g. user menu / label visible). | ☐ |

**Pass criteria:** S1–S3 all pass.

---

## 5. P0 – Critical Path (Must Pass for Release)

| # | Test case | Steps | Expected result | Pass? |
|---|-----------|--------|-----------------|------|
| P0-1 | Admin login end-to-end | Open QA URL → Verify Sign In → Enter admin credentials → Sign In → Verify success. | Login completed; user menu shows username. | ☐ |
| P0-2 | Back to Home and Cases navigation | After login: Back to Home → Cases → Public Cases → Open a case by ID → Back to Private Cases. | Each screen loads; Private Cases title/page visible. (Requires data loaded in DB.) | ☐ |
| P0-3 | Logout / session | After login, use user menu to sign out (if available). | Return to Sign In screen; cannot access protected pages without re-login. | ☐ |

**Pass criteria:** All P0 checks pass with no blockers.

---

## 6. P1 – High Priority

| # | Test case | Steps | Expected result | Pass? |
|---|-----------|--------|-----------------|------|
| P1-1 | Invalid login | Enter wrong username/password, click Sign In. | Error message; no login; no crash. | ☐ |
| P1-2 | Empty credentials | Leave username or password blank, click Sign In. | Validation message or clear error. | ☐ |
| P1-3 | Home navigation | From any inner screen, click “Back to Home” (or Home link). | Home/default landing page loads. | ☐ |
| P1-4 | Cases menu – Public | Login → Cases → Public Cases. | Public Cases list loads; case IDs visible (needs data in DB). | ☐ |
| P1-5 | Cases menu – Private | From Public Cases, use Back to Private Cases. | Private Cases page loads; title “Private Cases” visible. | ☐ |
| P1-6 | Open a case | From Cases list, click a case ID. | Case details (or expected view) opens. | ☐ |
| P1-7 | Page refresh after login | After login, refresh the page (F5). | Session preserved or clear re-login prompt. | ☐ |

---

## 7. P2 – Broader Regression (When Time Allows)

| # | Area | Examples |
|----|------|----------|
| P2-1 | **Different browsers** | Run Smoke + P0 on Edge, Firefox (or your supported set). |
| P2-2 | **Responsive / layout** | Resize window; check login and main screens for layout issues. |
| P2-3 | **Keyboard / accessibility** | Tab through login form; submit with Enter. |
| P2-4 | **Session timeout** | Leave app idle for timeout period; verify redirect to login and no crash. |
| P2-5 | **Multiple roles** | If you have other roles (e.g. viewer), login and basic navigation. |
| P2-6 | **Error handling** | Invalid URLs, network interruption simulation (if feasible). |

---

## 8. Execution Workflow (Pre-Release)

1. **Deploy** the release candidate to QA and note build/version.
2. **Load test data** in the database manually (users, cases, and any other data needed for the checklist).
3. **Run Smoke** (Section 4): S1 → S2 → S3. If any fail → stop, report, fix.
4. **Run P0** (Section 5): P0-1 → P0-2 → P0-3. If any fail → treat as release blocker unless waived.
5. **Run P1** (Section 6) when you can; log failures and decide if any are release blockers.
6. **Run P2** (Section 7) as time permits.
7. **Sign-off:** Release only when Smoke + P0 pass and P1 blockers (if any) are resolved or explicitly accepted.

You can either use the **Pass?** column in the tables below, or (recommended) open **test-plan/test-plan.html** in your browser to run and record the plan; use **Save report (HTML)** or **Save report (JSON)** to keep the run in your project.

---

## 9. Results and Reporting

- **Log:** For each run, record: build/version, QA URL, date, your name, and Pass/Fail per check (use the Pass? column or a simple spreadsheet).
- **Failures:** Log steps to reproduce, screenshot if possible, and severity (P0/P1/P2).

---

## 10. Maintaining This Plan

- **New features:** Add new rows to the Smoke / P0 / P1 tables for new critical flows.
- **Data needs:** If a new check needs specific DB data, note it in “Before You Run the Regression” (Section 2.1) and in the test steps.
- **QA URL/credentials:** Keep Section 2 in sync with your real QA URL and test user.

---

*Update the base URL, credentials, and test cases as your FV web app and environments change.*
