/**
 * FV Web App – selectors used by regression tests.
 * Aligned with ginger-automation flows (XPaths). Update if the app UI changes.
 */
export const Selectors = {
  // Login page
  signInLegend: "//legend[text()='Sign In']",
  usernameInput: "//input[@name='userInput_Input']",
  passwordInput: "//input[@name='passInput_Input']",
  signInButton: "//button[@name='okbtn_Button']",

  // Post-login
  userMenuLabel: "//div[@data-id='btnUserMenu']//label",

  // Navigation
  backToHome: "//a[.//span[@name='Home_NavbarItem']]",
  casesMenu: "//div[@data-id='btnCases']//label[contains(.,'Cases')]",
  publicCasesMenuItem: "//a[@name='Public_Cases_MenuItem']",
  privateCasesMenuItem: "//a[@name='Private_Cases_MenuItem']",
  firstCaseIdLink: "(//td[@data-field='CASE_ID']//a)[1]",
  backToPrivateCasesButton: "//div[@data-id='BackBtn']",
  privateCasesTitle: "//p[@data-id='title' and contains(text(),'Private Cases')]",

  // Global search on top (toolbar button with label "Global Search")
  globalSearch: "//div[@data-id='SearchImageGlobal']",
  // Global search panel (data-id="modules" = Search In dropdown, bootstrap-select)
  searchInMenu: "//div[@data-id='modules']//button[@data-toggle='dropdown']",
  searchInOptionCases: "//a[.//span[@name='Cases_Combo_Item']]",
  globalSearchValueInput: "//input[@name='value_Input' or @placeholder='Global value to search']",
  globalSearchViewButton: "//button[@name='btnView_Button']",
  caseGrid: "//td[@data-field='CASE_ID']",
  // Global search results area (accordion or grid)
  globalSearchResultsArea: "//div[@data-id='accModules'] | //td[@data-field='CASE_ID']",
  // Export data from grid: dropdown toggle that opens export menu
  gridExportButton:
    "//div[@data-toggle='dropdown' and contains(@class,'export')] | //div[@name='Assets/Grid/Export_32.png_Image']",
  // Export menu option: All to CSV - Offline
  exportAllToCsvOffline: "//a[@name='All_to_CSV_-_Offline_MenuItem']",
  // Popup / modal Yes button (e.g. after export confirmation)
  popupYesButton: "//button[contains(.,'Yes')] | //a[contains(.,'Yes')] | //*[@role='button' and contains(.,'Yes')]",
  // Notification shown when export file is ready (alert with "Completed Successfully")
  exportReadyNotification:
    "//div[contains(@class,'alert-success') and contains(.,'Completed Successfully')]",
  // Download button inside the export-ready notification
  exportDownloadButton: "//div[contains(@class,'alert-success')]//button[contains(.,'Download')]",
} as const;
