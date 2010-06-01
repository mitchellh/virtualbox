require File.join(File.dirname(__FILE__), '..', 'test_helper')

class DHCPServerTest < Test::Unit::TestCase
  setup do
    @interface = mock("interface")
    @parent = mock("parent")

    @klass = VirtualBox::DHCPServer
  end

  context "class methods" do
    context "populating relationships" do
      setup do
        @instance = mock("instance")
        @klass.stubs(:new).returns(@instance)
      end

      should "return a proxied collection" do
        result = @klass.populate_relationship(nil, [])
        assert result.is_a?(VirtualBox::Proxies::Collection)
      end

      should "call new for every interface" do
        collection = []
        5.times { |i| collection << mock("a#{i}") }

        expected_result = []
        new_seq = sequence("new_seq")
        collection.each do |item|
          expected_value = "instance-#{item.inspect}"
          @klass.expects(:new).with(item).in_sequence(new_seq).returns(expected_value)
          expected_result << expected_value
        end

        assert_equal expected_result, @klass.populate_relationship(@parent, collection)
      end
    end

    context "creating" do
      setup do
        @lib = mock("lib")
        @virtualbox = mock("virtualbox")
        @proxy = mock("proxy")

        @lib.stubs(:virtualbox).returns(@virtualbox)
        @parent.stubs(:lib).returns(@lib)
        @proxy.stubs(:parent).returns(@parent)
      end

      should "create the dhcp server" do
        name = :foo
        interface = mock("interface")
        result = mock("result")
        @virtualbox.expects(:create_dhcp_server).with(name).once.returns(interface)
        @klass.expects(:new).with(interface).returns(result)
        assert_equal result, @klass.create(@proxy, name)
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
      @instance.stubs(:interface).returns(@interface)
      @collection = VirtualBox::Proxies::Collection.new(@parent)
      @collection << @instance
    end

    context "saving" do
      setup do
        @instance.stubs(:save_changed_interface_attributes)
      end

      should "set configuration if something changed" do
        @instance.ip_address = "7"
        @interface.expects(:set_configuration).once
        @instance.save
      end

      should "not set configuration if nothing changed" do
        @interface.expects(:set_configuration).never
        @instance.save
      end

      should "save the changed attributes" do
        @instance.expects(:save_changed_interface_attributes).with(@instance.interface).once
        @instance.save
      end
    end

    context "destroying" do
      setup do
        @lib = mock("lib")
        @virtualbox = mock("virtualbox")
        @lib.stubs(:virtualbox).returns(@virtualbox)
        @parent.stubs(:lib).returns(@lib)

        @virtualbox.stubs(:remove_dhcp_server)
      end

      should "destroy the DHCP server" do
        @virtualbox.expects(:remove_dhcp_server).with(@interface).once
        @instance.destroy
      end

      should "remove from collection" do
        assert @collection.include?(@instance)
        @instance.destroy
        assert !@collection.include?(@instance)
      end
    end
  end
end
