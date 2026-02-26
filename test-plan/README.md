# FV Web – Test Plan Runner (no external software)

Run the regression test plan **directly on your machine** using only a browser. No TestRail, Zephyr, or other test-plan tools. No Node, no npm, no server.

## How to run

1. **Open the test plan**  
   Double-click **`test-plan.html`** (or open it in Chrome/Edge from the `test-plan` folder).  
   It works from your file system – no web server needed.

2. **Fill run details** (top of the page)  
   - Build / version  
   - QA URL  
   - Date (defaults to today)  
   - Tester name  

3. **Run your manual tests on QA**  
   In another tab, open your QA app and run through the steps. For each test in the plan, choose **Pass**, **Fail**, or **Skip**.

4. **Save the report**  
   - **Save report (HTML)** – downloads an HTML file you can store in your project (e.g. in a `test-results` folder) or share.  
   - **Save report (JSON)** – downloads a JSON file with the same run info and results for later use.

Save the downloaded files wherever you keep run evidence (e.g. `test-results/` in this project).

## Files

| File | Purpose |
|------|--------|
| **test-plan.html** | Open this to run the plan and record results. Single file, no dependencies. |
| **test-plan.json** | Source data for the plan (Smoke, P0, P1, P2). Edit to add/change tests; the HTML has a copy inside it – see “Updating the plan” below. |
| **README.md** | This file. |

## Updating the plan

- To **add or edit tests**: edit **test-plan.json**, then copy the whole JSON into **test-plan.html** where it says `const PLAN = { ... };` (replace the existing object so the HTML still works as a single file).
- Or edit the `PLAN` object directly inside **test-plan.html** if you prefer to keep one file only.

## Where this runs

- **Your system** – you open the HTML file in your browser (Chrome, Edge, etc.) on your PC.
- **No external “test plan” software** – everything is in this folder; no cloud tool or install required.

The plan matches **REGRESSION_TESTING_PLAN.md** in the project root (Smoke, P0, P1, P2). Load your QA test data in the DB first, then use this runner to execute and record the run.
