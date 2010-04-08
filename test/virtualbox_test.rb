require File.join(File.dirname(__FILE__), 'test_helper')

class VirtualBoxTest < Test::Unit::TestCase
  setup do
    VirtualBox::Command.stubs(:execute)
  end

  context "the version" do
    # TODO
  end
end