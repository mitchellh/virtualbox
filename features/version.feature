Feature: Global VirtualBox accessor
  As a virtualbox user
  I want to access global state information about virtualbox
  In order to drill down further into virtualbox

  Scenario: Reading the version
    When I try to read the virtualbox "version"
    Then the result should be "3.2.4"

  Scenario: Reading the revision
    When I try to read the virtualbox "revision"
    Then the result should be "62467"

  Scenario: Checking if VirtualBox supported
    When I try to read the virtualbox "supported?"
    Then the result should be "true"
