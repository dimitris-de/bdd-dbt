Feature: Validate the daily_operator_revenue dbt model

  Scenario: Ensure daily operator revenue has no negative values
    Given the dbt project is set up
    When I query the "daily_operator_revenue" model
    Then all revenue and ticket prices should be non-negative

  Scenario: Ensure the model contains data
    Given the dbt project is set up
    When I query the "daily_operator_revenue" model
    Then the result should not be empty
