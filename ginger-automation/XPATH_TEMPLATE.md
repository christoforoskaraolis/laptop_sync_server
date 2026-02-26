# XPath template for Ginger login flow

Use this to give the assistant the **exact xpaths** (or other locators) from your app so we can regenerate `02_login_admin.xml` with working UI element actions.

---

## How to get the xpaths

1. **Open your app’s login page** in Chrome.
2. **Right‑click** the element (e.g. username field) → **Inspect**.
3. In DevTools, **right‑click** the highlighted HTML node → **Copy** → **Copy XPath** (or **Copy full XPath**).
   - Or write a short xpath yourself, e.g. `//input[@name='username']` or `//*[@id='userInput']`.
4. Paste each xpath into the sections below.

If your app uses **id** or **name** and Ginger supports **ById** / **ByName**, you can give those instead and say “use ById” or “use ByName” for that step.

---

## 1. Verify login / Sign In screen

**Purpose:** Check that the login page is visible (e.g. “Sign In” title or login form).

- **LocateBy:** `ByXPath` (or ById/ByName if you prefer)
- **LocateValue (xpath or value):**  
  `_________________________________________________________`  
  Example: `//legend[text()='Sign In']` or `//form[@id='loginForm']`

---

## 2. Username field

**Purpose:** Clear and type the username.

- **LocateBy:** `ByXPath` (or ById/ByName)
- **LocateValue:**  
  `_________________________________________________________`  
  Example: `//input[@name='username']` or `//*[@id='userInput_Input']`

---

## 3. Password field

**Purpose:** Type the password.

- **LocateBy:** `ByXPath` (or ById/ByName)
- **LocateValue:**  
  `_________________________________________________________`  
  Example: `//input[@type='password']` or `//input[@name='passInput_Input']`

---

## 4. Sign In / Login button

**Purpose:** Click to submit login.

- **LocateBy:** `ByXPath` (or ById/ByName)
- **LocateValue:**  
  `_________________________________________________________`  
  Example: `//button[text()='Sign In']` or `//input[@name='okbtn_Button']`

---

## 5. Verify login success

**Purpose:** Confirm user is logged in (e.g. user menu, “Welcome”, or dashboard element).

- **LocateBy:** `ByXPath` (or ById/ByName)
- **LocateValue:**  
  `_________________________________________________________`  
  Example: `//div[@data-id='btnUserMenu']//label` or `//a[contains(.,'Logout')]`

**Optional – expected text (if step gets text and compares):**  
  `_________________________________________________________`  
  Example: `admin` or `Welcome, admin`

---

## Optional: Base URL

If different from current XML:

- **FV_URL:** `_________________________________________________________`  
  Example: `https://ilrnafvgqa01/fv-web-app`

---

## How to send this back

- Fill in the **LocateValue** (and optional **LocateBy** if not ByXPath) for each step.
- Paste the filled template (or a short list like “1: //legend[...], 2: //input[@name='user'], …”) into the chat and say: **“Use these xpaths to regenerate the Ginger XML.”**
- I’ll produce an updated `02_login_admin.xml` with these xpaths in the correct `ActUIElement` / `ActInputValue` entries so the steps run in Ginger.
