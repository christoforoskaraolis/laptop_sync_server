# Ginger-Style Business Flows for Web Application Testing

This folder contains **simple business flow** definitions you can use to test your web application. You can run them with [Ginger](https://github.com/Ginger-Automation/Ginger) or adapt them to other tools (Selenium, Playwright, Cypress, etc.).

---

## What’s included

| File | Format | Purpose |
|------|--------|---------|
| `flows/01_verify_homepage_loads.yaml` | YAML | Step-by-step flow: open URL, wait, verify content, take screenshot |
| `flows/01_verify_homepage_loads.feature` | Gherkin (BDD) | Same flow in Given/When/Then for Cucumber/SpecFlow or manual use |
| `flows/02_login_admin.yaml` | YAML | **Login flow**: open FV web app in Chrome, verify login page, log in (admin/admin4), verify success |
| `flows/02_login_admin.feature` | Gherkin (BDD) | Same login flow in Given/When/Then; use in Ginger (see [GINGER_IMPORT_GUIDE.md](GINGER_IMPORT_GUIDE.md)) |
| `flows/02_login_admin.xml` | XML | Same login flow as **Ginger-style Business Flow XML**; try import or use as reference (see [Using the XML in Ginger](#using-the-xml-in-ginger)) |

---

## Can I download the YAML and import it into Ginger?

**Short answer: no.** Ginger does not import our custom YAML format. Ginger uses its own **XML-based** project and script format (“Ginger Scripts”), so these YAML files are not directly importable.

**What you can do instead:**

1. **Use the .feature (Gherkin) file in Ginger**  
   Ginger supports **BDD / Gherkin**. You can:
   - Create or open a feature in Ginger and **paste** the contents of `02_login_admin.feature` (or type the scenarios using our steps).
   - Or use Ginger’s “Add Scenarios” / “Feature File” / “Plain English” flow and recreate the same steps from the `.feature` file.  
   **→ Step-by-step: see [GINGER_IMPORT_GUIDE.md](GINGER_IMPORT_GUIDE.md)** for copy/paste and running the scenario in Ginger.

2. **Use the YAML as a spec and build the flow in Ginger**  
   - Download or keep `02_login_admin.yaml` open.
   - In Ginger, create a new **Business Flow** (or equivalent).
   - Add each step from the YAML manually (Navigate → Wait → Verify login page → Set username → Set password → Click Login → Wait → Verify success), and map actions to your app’s real elements in Ginger’s UI.

3. **Manual test**  
   Use the step list in the “Flow: Login as Admin” section below as a checklist in the browser.

So: **YAML = spec only** for Ginger; **.feature = text you can reuse in Ginger’s BDD/feature flows**; the actual runnable flow is built inside Ginger (or via Ginger’s Gherkin automation).

---

## Quick start

### 1. Point the flow at your app

Edit `flows/01_verify_homepage_loads.yaml` and set your real URL:

```yaml
configuration:
  base_url: "https://your-web-app.com"   # your app URL
```

In the `.feature` file, change the URL in the step:

```gherkin
Given I open the web application at "https://your-web-app.com"
```

### 2. Run with Ginger (if you use Ginger)

1. Install Ginger: [Ginger by Amdocs](https://ginger.amdocs.com/) or [GitHub – Ginger-Automation/Ginger](https://github.com/Ginger-Automation/Ginger).
2. In Ginger, create or open a **Business Flow** and either:
   - Import/use the steps from `01_verify_homepage_loads.yaml` as a reference, or  
   - Recreate the same steps in the UI using the YAML as the specification.

Ginger uses its own project format; these files are designed as **readable specs** you can follow when building the flow inside Ginger.

### 3. Use as a manual test

Use the flow as a checklist:

1. Open the app at your `base_url`.
2. Wait until the page is fully loaded.
3. Check that the main content (e.g. `body` or your main container) is visible.
4. Check that the page has a title.
5. Take a screenshot and save it as `homepage_loaded`.

---

## Flow summary: “Verify homepage loads”

| Step | Action | What to do |
|------|--------|------------|
| 1 | Navigate | Open `base_url` in the browser |
| 2 | Wait | Wait for page load (e.g. 5 s) |
| 3 | Verify | Main content area is visible |
| 4 | Verify | Page title is present |
| 5 | Screenshot | Save “homepage_loaded” |

---

## Adding more flows

- Duplicate `01_verify_homepage_loads.yaml` and rename (e.g. `02_login_flow.yaml`).
- Change `flow_id`, `flow_name`, `description` and the `steps` to match your new scenario.
- Do the same for the `.feature` file if you use Gherkin.

If you tell me the next scenario (e.g. “search,” “checkout”), I can generate the next flow files in the same style.

---

## Flow: Login as Admin (FV Web App)

**Website:** `https://ilrnafvgqa01/fv-web-app` · **Browser:** Google Chrome · **Credentials:** admin / admin4

| Step | Action | What to do |
|------|--------|------------|
| 1 | Navigate | Open Chrome and go to `https://ilrnafvgqa01/fv-web-app` |
| 2 | Wait | Wait for the page to load |
| 3 | Verify | Page is open (URL contains `fv-web-app`) |
| 4 | Verify | Login page is visible (username or login form on screen) |
| 5 | Set value | Enter **admin** in the username field |
| 6 | Set value | Enter **admin4** in the password field |
| 7 | Click | Click the Login (or Sign in) button |
| 8 | Wait | Wait for the post-login page to load |
| 9 | Verify | Login is completed (e.g. dashboard, welcome text, or Logout link visible) |

**Manual test checklist:** Use `flows/02_login_admin.feature` or the steps above. In Ginger, recreate these steps in a Business Flow and point actions to your app’s real element IDs/names if the default locators in `02_login_admin.yaml` don’t match.

---

## Using the XML in Ginger

A **Ginger-style XML** for the login scenario is in **`flows/02_login_admin.xml`**. It contains the same steps and parameters as the YAML and .feature files, in XML form.

- **Try import:** In Ginger, use **File → Import** (or **Business Flows → Import**) if available, and select `02_login_admin.xml`. If your Ginger version supports importing this structure, the flow will appear.
- **Use as reference:** If import fails or isn’t supported, use the XML as a **spec**: open it next to Ginger and build the flow manually (add activities/actions and set parameters to match the XML).
- **Compare with Ginger’s format:** Create a small flow in Ginger, **export** it (e.g. to XML), then compare with `02_login_admin.xml` and adjust element/attribute names if you want to produce Ginger-native XML from this scenario later.

The XML uses a generic structure (`BusinessFlow`, `Activities`, `Activity`, `Parameters`, etc.). Ginger’s actual schema may use different tags or attributes; the comment at the top of the file explains this.
