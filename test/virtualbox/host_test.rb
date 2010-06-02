require File.join(File.dirname(__FILE__), '..', 'test_helper')

class HostTest < Test::Unit::TestCase
  setup do
    @parent = mock("parent")
    @klass = VirtualBox::Host
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
      @klass.any_instance.stubs(:populate_relationship)
    end

    should "load interface attribtues" do
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once
      @klass.new(@parent, @interface)
    end

    should "populate the relationships" do
      @klass.any_instance.expects(:populate_relationship).with(:network_interfaces, @interface).once
      @klass.new(@parent, @interface)
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
      end

      should "return a SystemProperties instance" do
        result = @klass.populate_relationship(nil, @interface)
        assert_equal @instance, result
      end

      should "call new for every shared folder" do
        @klass.expects(:new).with(nil, @interface).returns(@instance)
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
      should "save changed interface attributes" do
        @instance.expects(:save_changed_interface_attributes).with(@interface)
        @instance.save
      end
    end
  end
end
