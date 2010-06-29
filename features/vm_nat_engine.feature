Feature: Virtual Machine NAT Engine
  As a virtualbox library user
  I want to read and update the NAT engine on a network adapter

  Background:
    Given I find a VM identified by "test_vm_A"
    And the adapters are reset
    And the following adapters are set:
      | slot | type |
      |    1 | nat  |
    And the "network_adapters" relationship
    And the "nat_driver" relationship on collection item "1"

  Scenario: Reading the NAT engine
    Then the NAT network should exist
