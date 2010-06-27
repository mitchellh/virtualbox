Feature: Global Extra Data
  As a virtualbox library user
  I want to access and update global extra data

  Background:
    Given the global object
    And the "extra_data" relationship

  Scenario: Reading extra data
    Given the extra data of "global"
    Then all the extra data should match

  @unsafe
  Scenario: Writing extra data
    Given I set the extra data "VirtualBoxGemTest/Key" to "Value"
    And the extra data is saved
    And the extra data of "global"
    Then the extra data should include "VirtualBoxGemTest/Key" as "Value"
