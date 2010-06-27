Feature: Virtual Machine Shared Folders
  As a virtualbox library user
  I want to read and update shared folders

  Background:
    Given I find a VM identified by "test_vm_A"
    And I add a shared folder "foo" with path "/" via VBoxManage
    And I reload the VM
    And the "shared_folders" relationship

  Scenario: Reading Shared Folders
    Then the shared folder properties should match

  @unsafe
  Scenario: Creating Shared Folders
    Given no shared folder "bar" exists
    When I create a new shared folder "bar" with path "/baz"
    And I add the new record to the relationship
    And I save the model
    And I reload the VM info
    Then the shared folder properties should match

  @unsafe
  Scenario: Deleting Shared Folders
    When I delete the shared folder "foo"
    And I reload the VM info
    Then the shared folder "foo" should not exist
    Then the shared folder properties should match
