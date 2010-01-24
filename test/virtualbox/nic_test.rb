require File.join(File.dirname(__FILE__), '..', 'test_helper')

class NicTest < Test::Unit::TestCase
  setup do
    @data = {
      :nic1 => "bridged",
      :nic2 => "foo",
      :nic3 => "bar"
    }
    
    @caller = mock("caller")
  end
  
  context "saving" do
    setup do
      @nic = VirtualBox::Nic.populate_relationship(@caller, @data)
      @vmname = "myvm"
    end
    
    should "use the vmname strung through the save" do
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm #{@vmname} --nic1 foo")
      
      nic = @nic[0]
      nic.nic = "foo"
      nic.save(@vmname)
    end
    
    should "use the proper index" do
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm #{@vmname} --nic2 far")
      
      nic = @nic[1]
      nic.nic = "far"
      nic.save(@vmname)
    end
    
    should "not save the type [yet]" do
      VirtualBox::Command.expects(:vboxmanage).never
      
      nic = @nic[0]
      nic.type = "ZOO"
      assert nic.type_changed?
      nic.save(@vmname)
    end
  end
  
  context "populating relationships" do
    should "create the correct amount of objects" do
      value = VirtualBox::Nic.populate_relationship(@caller, @data)
      assert_equal 3, value.length
    end
  end
end