require File.expand_path("../../test_helper", __FILE__)

class USBControllerTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::USBController
    @interface = mock("interface")
  end

  context "initializing" do
    should "load attributes from the machine" do
      @klass.any_instance.expects(:initialize_attributes).with(@parent, @interface).once
      @klass.new(@parent, @interface)
    end
  end

  context "initializing attributes" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)
      @klass.any_instance.stubs(:populate_relationships)
    end

    should "load interface attribtues" do
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once
      @klass.new(@parent, @interface)
    end

    should "populate relationships" do
      @klass.any_instance.expects(:populate_relationships).with(@interface).once
      @klass.new(@parent, @interface)
    end

    should "setup the parent" do
      instance = @klass.new(@parent, @interface)
      assert_equal @parent, instance.parent
    end

    should "setup the interface" do
      instance = @klass.new(@parent, @interface)
      assert_equal @interface, instance.interface
    end

    should "not be dirty" do
      @instance = @klass.new(@parent, @interface)
      assert !@instance.changed?
    end

    should "be existing record" do
      @instance = @klass.new(@parent, @interface)
      assert !@instance.new_record?
    end
  end

  context "class methods" do
    context "populating relationship" do
      setup do
        @instance = mock("instance")

        @klass.stubs(:new).returns(@instance)

        @controller_interface = mock("controller_interface")
        @interface.stubs(:usb_controller).returns(@controller_interface)
      end

      should "return a USBController instance" do
        result = @klass.populate_relationship(nil, @interface)
        assert_equal @instance, result
      end

      should "call new with the interface" do
        @klass.expects(:new).with(@parent, @controller_interface).returns(@instance)
        result = @klass.populate_relationship(nil, @interface)
        assert_equal @instance, result
      end
    end

    context "saving relationship" do
      setup do
        @item = mock("item")
      end

      should "just call save on the item" do
        @item.expects(:save)
        @klass.save_relationship(nil, @item)
      end
    end
  end

  context "instance methods" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)
      @klass.any_instance.stubs(:populate_relationship)
      @instance = @klass.new(@parent, @interface)
    end

    context "saving" do
      setup do
        @session = mock("session")
        @machine = mock("machine")
        @usb_controller = mock("usb_controller")
        @session.stubs(:machine).returns(@machine)
        @machine.stubs(:usb_controller).returns(@usb_controller)
        @parent.stubs(:with_open_session).yields(@session)
      end

      should "save on the locked interface" do
        @instance.expects(:save_changed_interface_attributes).with(@usb_controller).once
        @instance.save
      end
    end
  end
end
