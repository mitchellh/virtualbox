require File.expand_path("../test_helper", __FILE__)

class VirtualBoxTest < Test::Unit::TestCase
  setup do
    VirtualBox::Command.stubs(:execute)
  end

  context "the version" do
    # TODO
  end
end
