Feature: Virtual Machine HW Virtualization
  As a virtualbox library user
  I want to read and update HW Virtualization settings

  Background:
    Given I find a VM identified by "test_vm_A"
    And I set the VM properties:
      | name         | value |
      | hwvirtex     | on    |
      | nestedpaging | on    |
    And I reload the VM
    And the "hw_virt" relationship

  Scenario: Reading
    Then the "HW virt" properties should match

  @unsafe
  Scenario: Updating
    When I set the relationship property "enabled" to "false"
    And I save the relationship
    And I reload the VM info
    Then the "HW virt" properties should match

  @unsafe
  Scenario: Updating and saving via VM
    When I set the relationship property "nested_paging" to "false"
    And I save the model
    And I reload the VM info
    Then the "HW virt" properties should match
