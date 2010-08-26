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

# Initialize the FFI stuff. This is typically done dynamically when
# FFI is initialized (on non-windows machines). Since the tests test
# the FFI classes, we force initialize a specific version here. It
# doesn't matter what version, since no actual FFI calls are made.
VirtualBox::COM::FFI.setup("3.2.x") unless defined?(VirtualBox::COM::FFI::Version_3_2_X)
