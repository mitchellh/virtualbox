require File.join(File.dirname(__FILE__), 'test_helper')

class VirtualBoxTest < Test::Unit::TestCase
  should "return version" do
    VirtualBox.expects(:execute).with("-v").returns("ver").once
    assert_equal "ver", VirtualBox.version
  end
end