Feature: Global Extra Data
  As a virtualbox library user
  I want to access and update global extra data

  Background:
    Given the global object
    And the "extra_data" relationship

  Scenario: Reading extra data
    Given the extra data of "global"
    Then all the extra data should match
