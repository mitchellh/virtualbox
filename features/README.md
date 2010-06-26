# VirtualBox Gem Feature Tests

**Warning: These tests actually hit the real VirtualBox software!**

The tests in this directory are _not_ meant as a replacement
for the unit tests in the `test/` directory. Instead, these
features are meant to test the actual integration of the
virtualbox gem with an actual VirtualBox installation.

Whereas the unit tests try to test every branch of the code in a
very prescribed, isolated environment, the feature tests do not
test specific branches of code, but test behavior of the gem.
The reasoning for both tests is that the unit tests test proper
behavior _within the library itself_ whereas these feature tests
test proper behavior _with the outside world_.

## Running Feature Tests

The easiest way to run these feature tests is via `rake` or the
`cucumber` binary. `rake` shown below:

    rake test:integration

## Feature Coverage

The test coverage of the features are purposefully not trying to
reach 100% branch coverage. They test the basic functionality (and
as much as the functionality as possible) to verify the library is
functional. If a bug is found, then a feature should be added to
reproduce and verify the bug no longer exists, but I'm not concerned
with getting 100% branch coverage right away.

For 100% branch coverage, see the unit tests, which do this.
