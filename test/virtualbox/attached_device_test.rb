require File.join(File.dirname(__FILE__), '..', 'test_helper')

class AttachedDeviceTest < Test::Unit::TestCase
  setup do
    @data = {
      :"foo controller-0-0" => "foomedium",
      :"foo controller-imageuuid-0-0" => "322f79fd-7da6-416f-a16f-e70066ccf165",
      :"foo controller-1-0" => "barmedium"
    }

    @vm = mock("vm")
    @vm.stubs(:name).returns("foo")
    
    @caller = mock("caller")
    @caller.stubs(:parent).returns(@vm)
    @caller.stubs(:name).returns("Foo Controller")
    
    # Stub execute to make sure nothing actually happens
    VirtualBox::Command.stubs(:execute).returns('')
  end
  
  context "destroying" do
    setup do
      @value = VirtualBox::AttachedDevice.populate_relationship(@caller, @data)
      @value = @value[0]
      
      @image = mock("image")
      @value.stubs(:image).returns(@image)
      
      VirtualBox::Command.stubs(:execute)
    end

    should "simply call destroy on each object when destroying the relationship" do
      obj_one = mock("one")
      obj_two = mock("two")

      obj_one.expects(:destroy).with("HELLO").once
      obj_two.expects(:destroy).with("HELLO").once

      VirtualBox::AttachedDevice.destroy_relationship(self, [obj_one, obj_two], "HELLO")
    end
    
    should "shell escape VM name and storage controller name" do
      shell_seq = sequence("shell_seq")
      VirtualBox::Command.expects(:shell_escape).with(@vm.name).in_sequence(shell_seq)
      VirtualBox::Command.expects(:shell_escape).with(@caller.name).in_sequence(shell_seq)
      VirtualBox::Command.expects(:vboxmanage).in_sequence(shell_seq)
      @value.destroy
    end
    
    should "not destroy image by default" do
      @image.expects(:destroy).never
      @value.destroy
    end
    
    should "destroy image if flag is set" do
      @image.expects(:destroy).once
      @value.destroy({
        :destroy_image => true
      })
    end
    
    should "ignore destroy image flag if image is nil" do
      @value.expects(:image).once.returns(nil)
      @value.destroy({
        :destroy_image => true
      })
    end
  end
  
  context "populating relationships" do
    setup do
      @value = VirtualBox::AttachedDevice.populate_relationship(@caller, @data)
    end
    
    should "create the correct amount of objects" do
      assert_equal 2, @value.length
    end
    
    should "create objects with proper values" do
      obj = @value[0]
      assert_equal "foomedium", obj.medium
      assert_equal "322f79fd-7da6-416f-a16f-e70066ccf165", obj.uuid
      assert_equal 0, obj.port
      
      obj = @value[1]
      assert_equal "barmedium", obj.medium
      assert_nil obj.uuid
      assert_equal 1, obj.port
    end
  end
end