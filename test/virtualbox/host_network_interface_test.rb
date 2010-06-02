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
      @instance.stubs(:parent).returns(@parent)
      @collection = VirtualBox::Proxies::Collection.new(@parent)
      @collection << @instance
    end

    context "dhcp server" do
      setup do
        @host = mock("host")
        @dhcp_servers = []
        @parent.stubs(:parent).returns(@host)
        @host.stubs(:dhcp_servers).returns(@dhcp_servers)
        @instance.stubs(:interface_type).returns(:host_only)

        @name = "foo"
        @instance.stubs(:name).returns(@name)
      end

      def stub_dhcp_server(name, prefix=true)
        name = "HostInterfaceNetworking-#{name}" if prefix

        dhcp = mock("dhcp")
        dhcp.stubs(:network_name).returns(name)
        dhcp
      end

      should "return nil if interface type isn't host only" do
        @instance.stubs(:interface_type).returns(:bridged)
        assert_nil @instance.dhcp_server
      end

      should "return the DHCP server if it finds one" do
        server = stub_dhcp_server(@name)
        @dhcp_servers << server
        assert_equal server, @instance.dhcp_server
      end

      should "create a DHCP server if it can't find one" do
        result = mock("result")
        @dhcp_servers.expects(:create).with("HostInterfaceNetworking-#{@name}").once.returns(result)
        assert_equal result, @instance.dhcp_server
      end
    end

    context "enabling static IPV4" do
      setup do
        @interface.stubs(:enable_static_ip_config)
        @instance.stubs(:reload)
      end

      should "enable the ip config" do
        ip = :foo
        netmask = :bar
        @interface.expects(:enable_static_ip_config).with(ip, netmask).once
        @instance.enable_static(ip, netmask)
      end

      should "by default use the current network mask" do
        ip = :foo
        @interface.expects(:enable_static_ip_config).with(ip, @instance.network_mask).once
        @instance.enable_static(ip)
      end

      should "reload the instance" do
        result = mock("result")
        @instance.expects(:reload).returns(result)
        assert_equal result, @instance.enable_static(:foo)
      end
    end

    context "reloading" do
      setup do
        @interface = mock("parent_interface")
        @parent.stubs(:interface).returns(@interface)
      end

      should "reload based on the interface found by the parent" do
        result = mock("result")
        @interface.expects(:find_host_network_interface_by_id).with(@instance.uuid).once.returns(result)
        @instance.expects(:initialize_attributes).with(result).once
        assert_equal @instance, @instance.reload
      end
    end

    context "destroying" do
      setup do
        @interface = mock("parent_interface")
        @progress = mock("progress")
        @progress.stubs(:wait)
        @parent.stubs(:interface).returns(@interface)
        @interface.stubs(:remove_host_only_network_interface).returns(@progress)
      end

      should "remove the network interface from VirtualBox" do
        @interface.expects(:remove_host_only_network_interface).with(@instance.uuid).returns(@progress)

        @instance.destroy
      end

      should "remove the instance from it's collection" do
        assert @collection.include?(@instance)
        @instance.destroy
        assert !@collection.include?(@instance)
      end
    end
  end
end
