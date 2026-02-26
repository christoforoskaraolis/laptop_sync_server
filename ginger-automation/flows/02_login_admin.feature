# Business Flow: Login as Admin (Gherkin / BDD)
# Website: https://ilrnafvgqa01/fv-web-app
# Username: admin | Password: admin4
#
# Use in Ginger: Features → Add scenario → Gherkin file → paste this file.
# See GINGER_IMPORT_GUIDE.md in this folder for step-by-step instructions.

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
