begin
  require File.expand_path('../../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
end

# ruby-debug, not necessary, but useful if we have it
begin
  require 'ruby-debug'
rescue LoadError; end

require 'contest'
require 'mocha'

# The actual library
require File.join(File.dirname(__FILE__), '..', 'lib', 'virtualbox')

# Data
class Test::Unit::TestCase
end

# Initialize the FFI stuff. This is typically done dynamically when
# FFI is initialized (on non-windows machines). Since the tests test
# the FFI classes, we force initialize a specific version here. It
# doesn't matter what version, since no actual FFI calls are made.
VirtualBox::COM::FFI.setup("3.1.x") unless defined?(VirtualBox::COM::FFI::Version_3_1_X)