Feature: Global Extra Data
  As a virtualbox library user
  I want to access and update global extra data

  Background:
    Given the global object
    And the "extra_data" relationship

  Scenario: Reading extra data
    When I get the extra data of "global"
    Then all the extra data should match

  @unsafe
  Scenario: Writing extra data
    When I set the extra data "VirtualBoxGemTest/Key" to "Value"
    And I save the relationship
    And I get the extra data of "global"
    Then the extra data should include "VirtualBoxGemTest/Key" as "Value"

  @unsafe
  Scenario: Deleting extra data
    When I set the extra data "VirtualBoxGemTest/Key" to "Value"
    And I save the relationship
    And I delete the extra data "VirtualBoxGemTest/Key"
    And I get the extra data of "global"
    Then the extra data should not include "VirtualBoxGemTest/Key"
