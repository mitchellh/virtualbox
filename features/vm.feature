Feature: Virtual Machine
  As a virtualbox library user
  I want to access information about specific virtual machines
  In order to get information about VMs in VirtualBox

  Scenario: Finding a non-existent VM
    When I find a VM identified by "this_should_never_exist1234"
    Then the VM should not exist

  Scenario: Finding a VM
    When I find a VM identified by "test_vm_A"
    Then the VM should exist
    And the properties should match
