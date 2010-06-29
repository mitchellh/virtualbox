Feature: Virtual Machine Shared Folders
  As a virtualbox library user
  I want to read and update shared folders

  Background:
    Given I find a VM identified by "test_vm_A"
    And I remove all shared folders
    And I reload the VM
    And the "shared_folders" relationship

  @unsafe
  Scenario: Reading Shared Folders
    Given a shared folder "foo" exists
    Then the shared folder properties should match

  @unsafe
  Scenario: Creating Shared Folders
    Given no shared folder "bar" exists
    When I create a new shared folder "bar" with path "/baz"
    And I add the new record to the relationship
    And I save the model
    And I reload the VM info
    Then the shared folder "bar" should exist
    Then the shared folder properties should match

  @unsafe
  Scenario: Updating Shared Folders
    Given a shared folder "foo" exists
    When I update the shared folder named "foo":
      | attribute | value     |
      | host_path | /new_path |
    And I save the model
    And I reload the VM info
    Then the shared folder properties should match

  @unsafe
  Scenario: Deleting Shared Folders
    Given a shared folder "foo" exists
    When I delete the shared folder "foo"
    And I reload the VM info
    Then the shared folder "foo" should not exist
    Then the shared folder properties should match
