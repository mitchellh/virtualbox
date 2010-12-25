require File.expand_path("../../test_helper", __FILE__)

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

    context "attached VMs" do
      setup do
        @parent_parent = mock("parentparent")
        @parent.stubs(:parent).returns(@parent_parent)

        @vms = []
        @parent_parent.stubs(:vms).returns(@vms)
      end

      def stub_vm(*interfaces)
        adapters = []
        vm = mock("vm")
        vm.stubs(:network_adapters).returns(adapters)

        interfaces.each do |name|
          adapter = mock("adapter")
          adapter.stubs(:enabled?).returns(true)
          adapter.stubs(:host_interface).returns(name)
          adapters << adapter
        end

        vm
      end

      should "return no VMs if none are using the interface" do
        assert @instance.attached_vms.empty?
      end

      should "return only the VMs which are using the interface" do
        name = "foo"
        @instance.stubs(:name).returns(name)
        result = stub_vm(name)
        @vms << stub_vm("bar")
        @vms << result
        @vms << stub_vm("baz")

        assert_equal [result], @instance.attached_vms
      end
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
      end

      should "not create a DHCP if specified and not found" do
        @dhcp_servers.expects(:create).never
        assert_nil @instance.dhcp_server(false)
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
        @instance.stubs(:dhcp_server).returns(nil)
        @instance.stubs(:interface_type).returns(:host_only)
      end

      should "do nothing if bridged" do
        @instance.stubs(:interface_type).returns(:bridged)
        @interface.expects(:remove_host_only_network_interface).never
        assert !@instance.destroy
      end

      should "remove the network interface from VirtualBox" do
        @interface.expects(:remove_host_only_network_interface).with(@instance.uuid).returns(@progress)

        @instance.destroy
      end

      should "destroy the DHCP server if it exists" do
        server = mock("server")
        @instance.stubs(:dhcp_server).returns(server)
        server.expects(:destroy).once

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
