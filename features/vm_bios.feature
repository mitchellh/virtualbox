Feature: Virtual Machine BIOS Settings
  As a virtualbox library user
  I want to read and update VM BIOS

  Background:
    Given I find a VM identified by "test_vm_A"
    And I set the VM properties:
      | name   | value |
      | acpi   | off   |
      | ioapic | off   |
    And I reload the VM
    And the "bios" relationship

  Scenario: Reading BIOS
    Then the BIOS properties should match

  @unsafe
  Scenario: Updating the BIOS
    When I set the relationship property "acpi_enabled" to "true"
    And I save the relationship
    And I reload the VM info
    Then the BIOS properties should match

  @unsafe
  Scenario: Updating the BIOS via the VM
    When I set the relationship property "io_apic_enabled" to "true"
    And I save the model
    And I reload the VM info
    Then the BIOS properties should match
