# Before everything, load virtualbox, of course
require 'spec'
require 'aruba'

require File.join(File.dirname(__FILE__), %W[.. .. lib virtualbox])

if !ENV["TEST_UNSAFE"]
  puts <<-MSG
========================================================================

For your own safety, unsafe tests (tests which modify actual VirtualBox
data), are disabled unless the environmental variable TEST_UNSAFE is
set. To enable unsafe tests, the easiest way is to do the following:

    TEST_UNSAFE=yes rake test:integration

========================================================================
MSG
end

Around('@unsafe') do |scenario, block|
  block.call if ENV["TEST_UNSAFE"]
end
