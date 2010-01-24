require File.join(File.dirname(__FILE__), '..', 'test_helper')

class CommandTest < Test::Unit::TestCase
  context "shell escaping" do
    should "convert value to string" do
      assert_nothing_raised do
        assert_equal "400", VirtualBox::Command.shell_escape(400)
      end
    end
  end
  
  context "testing command results" do
    setup do
      @command = "foo"
      VirtualBox::Command.stubs(:execute)
    end
    
    should "return true if the exit code is 0" do
      system("echo 'hello' 1>/dev/null")
      assert_equal 0, $?.to_i
      assert VirtualBox::Command.test(@command)
    end
    
    should "return false if the exit code is 1" do
      system("there_is_no_way_this_can_exist_1234567890")
      assert_not_equal 0, $?.to_i
      assert !VirtualBox::Command.test(@command)      
    end
  end
end