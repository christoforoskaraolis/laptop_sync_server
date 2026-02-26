# Simple Business Flow - Gherkin (BDD) format
# Run with Cucumber / SpecFlow / or use as manual test script

Feature: Homepage loads successfully
  As a user
  I want to open the web application
  So that I can see the homepage and use the app

  Scenario: Verify homepage loads and shows main content
    Given I open the web application at "https://example.com"
    When the page has finished loading
    Then the page title should be present
    And the main content area should be visible
    And I take a screenshot named "homepage_loaded"

  # Optional: add more scenarios later, e.g.:
  # Scenario: Verify login button is visible
  #   Given I am on the homepage
  #   Then I should see an element "Login" or "Sign in"
