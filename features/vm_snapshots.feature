Feature: Virtual Machine Snapshots
  As a virtualbox library user
  I want to manage a VM's snapshots

  Background:
    Given I find a VM identified by "test_vm_A"
    And the snapshots are cleared
    And the "current_snapshot" relationship

  Scenario: Reading the snapshots
    Given the following snapshot tree is created:
      | key | children  |
      | foo | bar,baz   |
      | bar | bar1,bar2 |
    And I reload the VM
    Then the snapshots should match

  Scenario: Taking a snapshot
    When I take a snapshot "foo"
    And I reload the VM info
    Then the snapshot "foo" should exist

  Scenario: Deleting a snapshot
    Given the snapshot "foo" is created
    And I reload the VM
    When I find the snapshot named "foo"
    And I destroy the snapshot
    And I reload the VM info
    Then the snapshot "foo" should not exist
