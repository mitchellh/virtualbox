require File.join(File.dirname(__FILE__), '..', 'test_helper')

class USBDeviceFilterTestTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::USBDeviceFilter
    @interface = mock("interface")
  end

  context "class methods" do
    context "populating relationships" do
      setup do
        @instance = mock("instance")

        @interface.stubs(:device_filters).returns([])
        @klass.stubs(:new).returns(@instance)
      end

      should "return a proxied collection" do
        result = @klass.populate_relationship(nil, @interface)
        assert result.is_a?(VirtualBox::Proxies::Collection)
      end

      should "call new for every interface" do
        collection = []
        @interface.stubs(:device_filters).returns(collection)
        5.times { |i| collection << mock("a#{i}") }

        expected_result = []
        new_seq = sequence("new_seq")
        collection.each do |item|
          expected_value = "instance-#{item.inspect}"
          @klass.expects(:new).with(item).in_sequence(new_seq).returns(expected_value)
          expected_result << expected_value
        end

        assert_equal expected_result, @klass.populate_relationship(@parent, @interface)
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

  context "initializing" do
    should "load attributes from the machine" do
      @klass.any_instance.expects(:initialize_attributes).with(@interface).once
      @klass.new(@interface)
    end
  end

  context "initializing attributes" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)
    end

    should "load interface attribtues" do
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once
      @klass.new(@interface)
    end

    should "not be dirty" do
      @instance = @klass.new(@interface)
      assert !@instance.changed?
    end

    should "be existing record" do
      @instance = @klass.new(@interface)
      assert !@instance.new_record?
    end
  end

  context "instance methods" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)

      @parent = mock("parent")
      @interface = mock("interface")
      @instance = @klass.new(@interface)
      @instance.stubs(:interface).returns(@interface)
      @instance.stubs(:parent).returns(@parent)
      @collection = VirtualBox::Proxies::Collection.new(@parent)
      @collection << @instance
    end
  end
end
