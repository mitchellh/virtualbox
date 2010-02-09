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

  context "validations" do
    setup do
      @ad = VirtualBox::AttachedDevice.new
      @ad.image = VirtualBox::DVD.empty_drive
      @ad.port = 7
      @ad.added_to_relationship(@caller)
    end

    should "be valid with all fields" do
      assert @ad.valid?
    end

    should "be invalid with no image" do
      @ad.image = nil
      assert !@ad.valid?
    end

    should "be invalid with no port" do
      @ad.port = nil
      assert !@ad.valid?
    end

    should "be invalid if not in a relationship" do
      @ad.write_attribute(:parent, nil)
      assert !@ad.valid?
    end
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

  context "saving an existing device" do
    setup do
      @value = VirtualBox::AttachedDevice.populate_relationship(@caller, mock_xml_doc)
      @value = @value[0]
      @value.image = VirtualBox::DVD.empty_drive
      assert @value.changed?
    end

    should "not do anything if the device isn't change" do
      @value.clear_dirty!
      assert !@value.changed?

      VirtualBox::Command.expects(:vboxmanage).never
      @value.save
    end

    should "call vboxmanage" do
      VirtualBox::Command.expects(:vboxmanage).once
      @value.save
    end

    should "return false and not call vboxmanage if invalid" do
      VirtualBox::Command.expects(:vboxmanage).never
      @value.expects(:valid?).returns(false)
      assert !@value.save
    end

    should "not call destroy if the port didn't change" do
      @value.expects(:destroy).never
      assert !@value.port_changed?
      assert @value.save
    end

    should "call destroy with the old port if the port changed" do
      @value.expects(:destroy).with({:port => @value.port}, false)
      @value.port = 7
      assert @value.port_changed?
      assert @value.save
    end

    should "call destroy with the raise errors flag" do
      @value.expects(:destroy).with(anything, true).once
      @value.port = 7
      @value.save(true)
    end
  end

  context "creating a new attached device" do
    setup do
      @image = VirtualBox::HardDrive.new
      @ad = VirtualBox::AttachedDevice.new
      @ad.image = @image
      @ad.port = 3
    end

    should "return false and not call vboxmanage if invalid" do
      VirtualBox::Command.expects(:vboxmanage).never
      @ad.expects(:valid?).returns(false)
      assert !@ad.save
    end

    should "raise a ValidationFailedException if invalid and raise_errors is true" do
      @ad.expects(:valid?).returns(false)
      assert_raises(VirtualBox::Exceptions::ValidationFailedException) {
        @ad.save(true)
      }
    end

    context "has a parent" do
      setup do
        @ad.added_to_relationship(@caller)
        VirtualBox::Command.stubs(:vboxmanage)
      end

      should "not call destroy since its a new record" do
        @ad.expects(:destroy).never
        assert @ad.save
      end

      should "call the proper vboxcommand" do
        VirtualBox::Command.expects(:vboxmanage).with("storageattach", @vm.name, "--storagectl", @caller.name, "--port", @ad.port, "--device", "0", "--type", @image.image_type, "--medium", @ad.medium)
        @ad.save
      end

      should "return false if the command failed" do
        VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
        assert !@ad.save
      end

      should "return true if the command was a success" do
        assert @ad.save
      end

      should "raise an exception if true sent to save and error occured" do
        VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
        assert_raises(VirtualBox::Exceptions::CommandFailedException) {
          @ad.save(true)
        }
      end

      should "not be a new record after saving" do
        assert @ad.new_record?
        assert @ad.save
        assert !@ad.new_record?
      end

      should "not be changed after saving" do
        assert @ad.changed?
        assert @ad.save
        assert !@ad.changed?
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
      @value = VirtualBox::AttachedDevice.populate_relationship(@caller, mock_xml_doc)
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

    should "destroy with the specified port if set" do
      VirtualBox::Command.expects(:vboxmanage).with("storageattach", @vm.name, "--storagectl", @caller.name, "--port", 80, "--device", "0", "--medium", "none")
      @value.destroy(:port => 80)
    end

    should "destroy with the default port if not other port is specified" do
      VirtualBox::Command.expects(:vboxmanage).with("storageattach", @vm.name, "--storagectl", @caller.name, "--port", @value.port, "--device", "0", "--medium", "none")
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

    should "return false if destroy failed" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert !@value.destroy
    end

    should "raise an exception if destroy failed and an error occured" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @value.destroy({}, true)
      }
    end

    should "forward raise_errors flag to image.destroy" do
      @image.expects(:destroy).with(true).once
      @value.destroy({:destroy_image => true}, true)
    end
  end

  context "populating relationships" do
    setup do
      @value = VirtualBox::AttachedDevice.populate_relationship(@caller, mock_xml_doc)
    end

    should "create the correct amount of objects" do
      assert_equal 2, @value.length
    end

    should "create objects with proper values" do
      obj = @value[0]
      assert_equal "none", obj.medium
      assert_equal "2c16dd48-4cf1-497e-98fa-84ed55cfe71f", obj.uuid
      assert_equal "0", obj.port

      obj = @value[1]
      assert_equal "none", obj.medium
      assert_nil obj.uuid
      assert_equal "1", obj.port
    end
  end
end