require File.join(File.dirname(__FILE__), '..', 'test_helper')

class HostNetworkInterfaceTest < Test::Unit::TestCase
  setup do
    @interface = mock("interface")
    @parent = mock("parent")

    @klass = VirtualBox::HostNetworkInterface
  end

  context "class methods" do
    context "populating relationships" do
      setup do
        @instance = mock("instance")

        @interface.stubs(:network_interfaces).returns([])
        @klass.stubs(:new).returns(@instance)
      end

      should "return a proxied collection" do
        result = @klass.populate_relationship(nil, @interface)
        assert result.is_a?(VirtualBox::Proxies::Collection)
      end

      should "call new for every interface" do
        collection = []
        @interface.stubs(:network_interfaces).returns(collection)
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

    context "creating" do
      setup do
        @interface = mock("interface")
        @inet = mock("inet")
        @progress = mock("progress")
      end

      should "create and return new instance" do
        result = mock("result")
        @interface.expects(:create_host_only_network_interface).returns([@inet, @progress]).once
        @progress.expects(:wait)
        @klass.expects(:new).with(@inet).returns(result)

        assert_equal result, @klass.create(nil, @interface)
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
      @klass.any_instance.stubs(:initialize_attributes)

      @parent = mock("parent")
      @interface = mock("interface")
      @instance = @klass.new(@interface)
      @collection = VirtualBox::Proxies::Collection.new(@parent)
      @collection << @instance
    end

    # Coming soon
  end
end
