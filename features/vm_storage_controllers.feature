Feature: Virtual Machine Storage Controllers
  As a virtualbox library user
  I want to read and update storage controllers on a VM

  Background:
    Given I find a VM identified by "test_vm_A"
    And the "storage_controllers" relationship

  Scenario: Reading Storage Controllers
    Then the number of storage controllers should match
    And the storage controller properties should match
