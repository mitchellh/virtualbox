Feature: Virtual Machine Network Adapters
  As a virtualbox library user
  I want to read and update network adapters

  Background:
    Given I find a VM identified by "test_vm_A"
    And the "network_adapters" relationship

  Scenario: Reading Shared Folders
    Then the network adapter properties should match
