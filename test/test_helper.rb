# ruby-debug, not necessary, but useful if we have it
begin
  require 'ruby-debug'
rescue LoadError; end

require 'contest'
require 'mocha'
require 'virtualbox'

# Data
class Test::Unit::TestCase
end

# Set the interface version manually since we don't do detection in tests
VirtualBox::COM::Util.set_interface_version("4.0.x")
