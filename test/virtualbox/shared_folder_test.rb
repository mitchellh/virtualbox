require File.join(File.dirname(__FILE__), '..', 'test_helper')

class SharedFolderTest < Test::Unit::TestCase
  setup do
    @data = {
      :sharedfoldernamemachinemapping1 => "foofolder",
      :sharedfolderpathmachinemapping1 => "/foo",
      :sharedfoldernamemachinemapping2 => "barfolder",
      :sharedfolderpathmachinemapping2 => "/bar"
    }
    
    @caller = mock("caller")
    @caller.stubs(:name).returns("foo")
    
    VirtualBox::Command.stubs(:execute)
  end
  
  context "destroying" do
    setup do
      @value = VirtualBox::SharedFolder.populate_relationship(@caller, @data)
      @value = @value[0]
    end
    
    should "call the proper command" do
      VirtualBox::Command.expects(:vboxmanage).with("sharedfolder remove #{@caller.name} --name #{@value.name}").once
      assert @value.destroy
    end
    
    should "shell escape VM name and storage controller name" do
      shell_seq = sequence("shell_seq")
      VirtualBox::Command.expects(:shell_escape).with(@caller.name).in_sequence(shell_seq)
      VirtualBox::Command.expects(:shell_escape).with(@value.name).in_sequence(shell_seq)
      VirtualBox::Command.expects(:vboxmanage).in_sequence(shell_seq)
      assert @value.destroy
    end
    
    should "return false if destroy failed" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert !@value.destroy
    end
    
    should "raise an exception if destroy failed and an error occured" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @value.destroy(true)
      }
    end
  end
  
  context "populating relationships" do
    setup do
      @value = VirtualBox::SharedFolder.populate_relationship(@caller, @data)
    end

    should "create the correct amount of objects" do
      assert_equal 2, @value.length
    end
    
    should "parse the proper data" do
      value = @value[0]
      assert_equal "foofolder", value.name
      assert_equal "/foo", value.hostpath
      
      value = @value[1]
      assert_equal "barfolder", value.name
      assert_equal "/bar", value.hostpath
    end
  end
end