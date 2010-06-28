Feature: Virtual Machine Network Adapters
  As a virtualbox library user
  I want to read and update network adapters

  Background:
    Given I find a VM identified by "test_vm_A"
    And the "network_adapters" relationship

  @unsafe
  Scenario: Reading adapters
    Given the adapters are reset
    And the following adapters are set:
      | slot | type |
      |    1 | nat  |
    Then the network adapter properties should match

  @unsafe
  Scenario: Updating adapters
    Given the adapters are reset
    And the following adapters are set:
      | slot | type     |
      |    1 | nat      |
    When I update the adapter in slot "1"
    And I set the property "cable_connected" to "false"
    And I save the VM
    And I reload the VM info
    Then the network adapter properties should match
