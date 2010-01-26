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
  
  context "medium" do
    setup do
      @ad = VirtualBox::AttachedDevice.new
      @hd = VirtualBox::HardDrive.new
      @hd.write_attribute(:uuid, @uuid)
    end
    
    should "be 'none' when image is nil" do
      assert_equal "none", @ad.medium
    end
    
    should "be the uuid of the image if its not nil" do
      @ad.image = @hd
      assert_equal @hd.uuid, @ad.medium
    end
    
    should "be 'emptydrive' if the image is an empty drive" do
      @ad.image = VirtualBox::DVD.empty_drive
      assert_equal "emptydrive", @ad.medium
    end
  end
  
  context "creating a new attached device" do
    setup do
      @image = VirtualBox::HardDrive.new
      @ad = VirtualBox::AttachedDevice.new
      @ad.image = @image
      @ad.port = 3
    end
    
    should "call create on save if its a new record" do
      @ad.expects(:create).once
      @ad.save
    end
    
    should "raise a NoParentException if it wasn't added to a relationship" do
      assert_raises(VirtualBox::Exceptions::NoParentException) {
        @ad.save
      }
    end
    
    context "has a parent" do
      setup do
        @ad.added_to_relationship(@caller)
        VirtualBox::Command.stubs(:vboxmanage)
      end
      
      should "raise an InvalidObjectException if no image is set" do
        @ad.image = nil
        assert_raises(VirtualBox::Exceptions::InvalidObjectException) {
          @ad.save
        }
      end

      should "call the proper vboxcommand" do
        VirtualBox::Command.expects(:vboxmanage).with("storageattach #{@vm.name} --storagectl #{VirtualBox::Command.shell_escape(@caller.name)} --port #{@ad.port} --device 0 --type #{@image.image_type} --medium #{@ad.medium}")
        @ad.save
      end

      should "return false if the command failed" do
        VirtualBox::Command.expects(:success?).returns(false)
        assert !@ad.save
      end

      should "return true if the command was a success" do
        VirtualBox::Command.expects(:success?).returns(true)
        assert @ad.save
      end
      
      should "raise an exception if true sent to save and error occured" do
        VirtualBox::Command.expects(:success?).returns(false)
        assert_raises(VirtualBox::Exceptions::CommandFailedException) {
          @ad.save(true)
        }
      end
    end
  end
  
  context "constructor" do
    should "call populate_from_data if 3 args are given" do
      VirtualBox::AttachedDevice.any_instance.expects(:populate_from_data).with(1,2,3).once
      VirtualBox::AttachedDevice.new(1,2,3)
    end
    
    should "call populate_attributes if 1 arg is given" do
      VirtualBox::AttachedDevice.any_instance.expects(:populate_attributes).with(1).once
      ad = VirtualBox::AttachedDevice.new(1)
      assert ad.new_record?
    end
    
    should "raise a NoMethodError if anything other than 0,1,or 3 arguments" do
      # 9 seems like a reasonable max (maybe just a bit unreasonable!)
      2.upto(9) do |i|
        next if i == 3
        args = Array.new(i, "A")
        
        assert_raises(NoMethodError) {
          VirtualBox::AttachedDevice.new(*args)
        }
      end
    end
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
      assert_equal "none", obj.medium
      assert_equal "322f79fd-7da6-416f-a16f-e70066ccf165", obj.uuid
      assert_equal 0, obj.port
      
      obj = @value[1]
      assert_equal "none", obj.medium
      assert_nil obj.uuid
      assert_equal 1, obj.port
    end
  end
end