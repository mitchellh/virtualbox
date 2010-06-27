Feature: Virtual Machine CPU Settings
  As a virtualbox library user
  I want to read and update VM CPU settings

  Background:
    Given I find a VM identified by "test_vm_A"
    And I set the VM properties:
      | name     | value |
      | pae      | off   |
      | synthcpu | off   |
    And I reload the VM
    And the "cpu" relationship

  Scenario: Reading CPU settings
    Then the "CPU" properties should match

  @unsafe
  Scenario: Updating the CPU settings
    When I set the relationship property "pae" to "true"
    And I save the relationship
    And I reload the VM info
    Then the "CPU" properties should match

  @unsafe
  Scenario: Updating the CPU settings via the VM
    When I set the relationship property "synthetic" to "true"
    And I save the model
    And I reload the VM info
    Then the "CPU" properties should match
