Feature: VirtualBox version information
  As a virtualbox library user
  I want to access information about the installed version
  In order to determine if I support this version of VirtualBox

  Scenario: Reading the version
    When I try to read the virtualbox "version"
    Then the result should match output

  Scenario: Reading the revision
    When I try to read the virtualbox "revision"
    Then the result should match output

  Scenario: Checking if VirtualBox supported
    When I try to read the virtualbox "supported?"
    Then the result should match output
