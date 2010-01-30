require File.join(File.dirname(__FILE__), 'test_helper')

class VirtualBoxTest < Test::Unit::TestCase
  setup do
    VirtualBox::Command.stubs(:execute)
  end
  
  context "the version" do
    should "return version" do
      VirtualBox::Command.expects(:vboxmanage).with("-v").returns("ver").once
      assert_equal "ver", VirtualBox.version
    end
    
    should "chomp the string" do
      VirtualBox::Command.expects(:vboxmanage).with("-v").returns("ver    \n\n").once
      assert_equal "ver", VirtualBox.version      
    end
  end
end