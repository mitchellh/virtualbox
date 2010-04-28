require File.join(File.dirname(__FILE__), '..', 'test_helper')

class USBDeviceFilterTestTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::USBDeviceFilter
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
    end

    should "load interface attribtues" do
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once
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

        @device_filters = [mock("device_filters")]
        @interface.stubs(:device_filters).returns(@device_filters)
      end

      should "return a collection" do
        result = @klass.populate_relationship(nil, @interface)
        assert result.is_a?(VirtualBox::Proxies::Collection)
      end

      should "call new for every filter" do
        @device_filters.clear
        5.times { |i| @device_filters << mock("m#{i}") }

        expected_result = []
        new_seq = sequence("new_seq")
        @device_filters.each do |filter|
          expected_value = "instance-#{filter.inspect}"
          @klass.expects(:new).with(filter).in_sequence(new_seq).returns(expected_value)
          expected_result << expected_value
        end

        assert_equal expected_result, @klass.populate_relationship(nil, @interface)
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
      @instance = @klass.new(@parent, @interface)
    end
  end
end