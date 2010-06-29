Feature: Virtual Machine NAT Engine
  As a virtualbox library user
  I want to read and update the NAT engine on a network adapter

  Background:
    Given I find a VM identified by "test_vm_A"
    And the forwarded ports are cleared
    And the adapters are reset
    And the following adapters are set:
      | slot | type |
      |    1 | nat  |
    And the "network_adapters" relationship
    And the "nat_driver" relationship on collection item "1"

  Scenario: Reading the NAT engine
    Then the NAT network should exist

  @unsafe
  Scenario: Reading Forwarded Ports
    Given I read the adapter in slot "1"
    And I create a forwarded port named "ssh" from "22" to "2222" via VBoxManage
    And I reload the VM
    And I read the adapter in slot "1"
    Then the forwarded port "ssh" should exist
    And the forwarded ports should match

  @unsafe
  Scenario: Creating Forwarded Ports
    Given I read the adapter in slot "1"
    When I create a forwarded port named "ssh" from "22" to "2222"
    And I save the relationship
    And I reload the VM info
    Then the forwarded port "ssh" should exist
    And the forwarded ports should match

  @unsafe
  Scenario: Deleting Forwarded Ports
    Given I read the adapter in slot "1"
    And I create a forwarded port named "ssh" from "22" to "2222" via VBoxManage
    And I reload the VM
    And I read the adapter in slot "1"
    When I delete the forwarded port named "ssh"
    And I reload the VM info
    Then the forwarded port "ssh" should not exist
