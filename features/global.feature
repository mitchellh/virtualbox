Feature: Global Data
  As a virtualbox library user
  I want to access information about the global state of VirtualBox
  In order to get information about my environment

  Scenario: Reading the VMs
    Given the global object
    When I read the "vms"
    Then I should get a matching length for "vms"

  Scenario: Reading the hard drives
    Given the global object
    When I read the media "hard drives"
    Then I should get a matching length of media items

  Scenario: Reading the dvds
    Given the global object
    When I read the media "dvds"
    Then I should get a matching length of media items
