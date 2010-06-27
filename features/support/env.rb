# Before everything, load virtualbox, of course
require 'spec'
require 'aruba'
require File.join(File.dirname(__FILE__), %W[.. .. lib virtualbox])

# Configuration settings/info
IntegrationInfo = {
  :test_unsafe => !!ENV["TEST_UNSAFE"],
  :vm_name => "test_vm"
}
