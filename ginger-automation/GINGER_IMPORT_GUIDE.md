# Use the .feature (Gherkin) in Ginger’s BDD flow

This guide shows how to **copy/paste or recreate** the login scenario from `flows/02_login_admin.feature` in Ginger so you can run it there.

---

## Step 1: Open the Gherkin text to paste

Open this file in your project:

**`flows/02_login_admin.feature`**

Copy **all** of its contents (from `# Business Flow…` down to the last `Then login is completed`). Or use the copy-ready block below.

---

## Step 2: In Ginger – create or open a Feature

1. Open **Ginger** (desktop app or Ginger on Web, depending on your setup).
2. Open your **Project** (or create one).
3. Go to **Features** (or **BDD** / **Gherkin**).
4. Either:
   - **Create a new Feature** (e.g. “Admin login to FV Web App”), or  
   - **Open an existing Feature** where you want this scenario.

---

## Step 3: Add the scenario via “Gherkin file” / paste

1. Use **“Add scenario”** (or **“Add a scenario”**).
2. Choose **“Gherkin file”** or **“Gherkin”** / **“Manually write scenario”** (wording may vary).
3. **Paste** the entire contents of `02_login_admin.feature` into the Gherkin editor.

   If your UI asks for “scenario text” only, paste just the **Scenario** block (from `Scenario:` down to `Then login is completed`), and set the Feature title/description separately if needed.

4. Save / apply so the feature and scenario are stored.

---

## Step 4: Generate or link step definitions (so it can run)

Ginger can generate automation for Gherkin steps:

1. After the scenario is added, use **“Generate missing code”** or **“Generate Code”** for the new steps (or run once and let the AI/Recorder suggest code).
2. Point steps at your app:
   - **“I open … in Google Chrome”** → open Chrome and navigate to the URL.
   - **“I enter … in the username field”** → type in the username input.
   - **“I enter … in the password field”** → type in the password input.
   - **“I click the Login button”** → click the login/submit control.
   - **“login is completed”** → assert dashboard/welcome or logout is visible.

3. Adjust **elements/locators** (IDs, names, XPath) to match your real login page if the default ones don’t fit.

---

## Copy-ready Gherkin (login scenario)

If you prefer to copy from here, use the block below. It’s the same as `flows/02_login_admin.feature`.

```gherkin
# Business Flow: Login as Admin (Gherkin / BDD)
# Website: https://ilrnafvgqa01/fv-web-app
# Username: admin | Password: admin4

Feature: Admin login to FV Web App
  As an admin user
  I want to log in to the FV web application
  So that I can access the application after login

  Scenario: Open site in Chrome, verify login page, log in as admin, verify success
    Given I open "https://ilrnafvgqa01/fv-web-app" in Google Chrome
    When the page has finished loading
    Then the page is open and the URL contains "fv-web-app"
    And the login page is visible
    When I enter "admin" in the username field
    And I enter "admin4" in the password field
    And I click the Login button
    And I wait for the page to load after login
    Then login is completed
```

---

## Quick checklist

| # | What to do |
|---|------------|
| 1 | Copy `flows/02_login_admin.feature` (or the block above). |
| 2 | In Ginger: Features → Add scenario → Gherkin / manual. |
| 3 | Paste the Gherkin and save. |
| 4 | Generate/link step code and set locators for your login page. |
| 5 | Run the scenario in Ginger. |

If your product is **Amdocs AI Test** (web), use **Features → Add a scenario → Gherkin file** and paste the same content there.

---

## XML business flow (Ginger-style)

A **Ginger-style XML** for the same login scenario is in **`flows/02_login_admin.xml`**. It contains the same steps and parameters as the YAML and .feature files, in XML form.

- **Try import:** In Ginger, use **File → Import** or **Business Flows → Import** (if available) and select `02_login_admin.xml`. If your version supports this structure, the flow will appear.
- **Use as reference:** If import fails, open `02_login_admin.xml` next to Ginger and build the flow manually (add activities/actions and set parameters to match the XML).
- **Compare with Ginger’s format:** Create a small flow in Ginger, **export** it to XML, then compare with `02_login_admin.xml` and adjust element/attribute names if you want Ginger-native XML later.

The XML uses generic tags (`BusinessFlow`, `Activities`, `Activity`, `Parameters`, etc.). Ginger’s actual schema may differ; see the comment at the top of `02_login_admin.xml`.
