require File.join(File.dirname(__FILE__), '..', 'test_helper')

class CommandTest < Test::Unit::TestCase
  context "shell escaping" do
    should "convert value to string" do
      assert_nothing_raised do
        assert_equal "400", VirtualBox::Command.shell_escape(400)
      end
    end
  end

  context "executing commands" do
    should "use backticks to execute the command" do
      VirtualBox::Command.expects(:`).with("foo").once
      VirtualBox::Command.execute("foo")
    end

    should "return the result of the execution" do
      VirtualBox::Command.expects(:`).with("foo").returns("bar").once
      assert_equal "bar", VirtualBox::Command.execute("foo")
    end
  end

  context "vbox commands" do
    should "call 'vboxmanage' followed by command" do
      VirtualBox::Command.expects(:execute).with("VBoxManage -q foo")
      VirtualBox::Command.stubs(:success?).returns(true)
      VirtualBox::Command.vboxmanage("foo")
    end

    should "call the custom vboxmanage executable if set" do
      VirtualBox::Command.vboxmanage = "barf"
      VirtualBox::Command.expects(:execute).with("barf -q foo")
      VirtualBox::Command.stubs(:success?).returns(true)
      VirtualBox::Command.vboxmanage("foo")
      VirtualBox::Command.vboxmanage = "VBoxManage"
    end

    should "raise a CommandFailedException if it failed" do
      VirtualBox::Command.expects(:execute).with("VBoxManage -q foo")
      VirtualBox::Command.stubs(:success?).returns(false)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        VirtualBox::Command.vboxmanage("foo")
      }
    end

    should "call vboxmanage with multiple arguments" do
      VirtualBox::Command.expects(:execute).with("VBoxManage -q foo bar baz --bak bax")
      VirtualBox::Command.vboxmanage("foo", "bar", "baz", "--bak", "bax")
    end

    should "shell escape all arguments" do
      VirtualBox::Command.expects(:execute).with("VBoxManage -q foo\\ bar baz another\\ string")
      VirtualBox::Command.vboxmanage("foo bar", "baz", "another string")
    end

    should "convert arguments to strings" do
      VirtualBox::Command.expects(:execute).with("VBoxManage -q isastring 8")
      VirtualBox::Command.vboxmanage(:isastring, 8)
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