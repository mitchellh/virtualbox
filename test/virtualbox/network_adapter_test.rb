require File.expand_path("../../test_helper", __FILE__)

class NetworkAdapterTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::NetworkAdapter
    @interface = mock("interface")
    @parent = mock("parent")
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

      @instance = @klass.new(@parent, @interface)
    end

    should "load interface attribtues" do
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once
      @klass.new(@parent, @interface)
    end

    should "setup the parent" do
      assert_equal @parent, @instance.parent
    end

    should "setup the interface" do
      assert_equal @interface, @instance.interface
    end

    should "not be dirty" do
      assert !@instance.changed?
    end

    should "be existing record" do
      assert !@instance.new_record?
    end
  end

  context "class methods" do
    context "populating relationship" do
      setup do
        @instance = mock("instance")
        @klass.stubs(:new).returns(@instance)

        @count = 5
        @vbox = mock("vbox")
        @system_properties = mock("sys_props")
        @interface.stubs(:parent).returns(@vbox)
        @vbox.stubs(:system_properties).returns(@system_properties)
        @system_properties.stubs(:network_adapter_count).returns(@count)
      end

      should "return a proxied collection" do
        @system_properties.stubs(:network_adapter_count).returns(0)
        result = @klass.populate_relationship(nil, @interface)
        assert result.is_a?(VirtualBox::Proxies::Collection)
      end

      should "call new for every shared folder" do
        expected_result = []
        new_seq = sequence("new_seq")
        @count.times do |i|
          expected_value = "instance-#{i}"
          adapter = mock("adapter#{i}")
          @interface.expects(:get_network_adapter).with(i).returns(adapter).in_sequence(new_seq)
          @klass.expects(:new).with(@parent, adapter).in_sequence(new_seq).returns(expected_value)
          expected_result << expected_value
        end

        assert_equal expected_result, @klass.populate_relationship(@parent, @interface)
      end
    end

    context "saving relationship" do
      should "call save on each item" do
        items = (1..5).to_a.collect do |i|
          item = mock("item-#{i}")
          item.expects(:save).once
          item
        end

        @klass.save_relationship(nil, items)
      end
    end
  end

  context "instance methods" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)
      @instance = @klass.new(@parent, @interface)
    end

    context "host interface object" do
      setup do
        @network_interfaces = []
        @host = mock("host")
        VirtualBox::Global.global.stubs(:host).returns(@host)
        @host.stubs(:network_interfaces).returns(@network_interfaces)
      end

      def stub_interface(name)
        interface = mock("interface")
        interface.stubs(:name).returns(name)
        @network_interfaces << interface
        interface
      end

      should "return the network interface associated with the adapter" do
        name = "foo"
        result = stub_interface(name)
        @instance.host_interface = name
        assert_equal result, @instance.host_interface_object
      end

      should "return nil if the interface is not found" do
        stub_interface("foo")
        @instance.host_interface = "bar"
        assert_nil @instance.host_interface_object
      end
    end

    context "saving" do
      setup do
        @adapter = mock("adapter")
        @instance.stubs(:modify_adapter).yields(@adapter)
      end

      should "save the attachment type and interface attributes on the open adapter" do
        @instance.expects(:save_attachment_type).with(@adapter).once
        @instance.expects(:save_changed_interface_attributes).with(@adapter).once
        @instance.expects(:save_relationships).once
        @instance.save
      end
    end

    context "saving attachment type" do
      setup do
        @adapter = mock("adapter")
        @instance.attachment_type = :nat
      end

      should "do nothing if attachment type is not changed" do
        @instance.clear_dirty!
        assert !@instance.attachment_type_changed?
        @instance.expects(:attach_to_nat).never

        @instance.save_attachment_type(@adapter)
      end

      should "run the proper method if it has changed" do
        @adapter.expects(:attach_to_nat).once
        @instance.save_attachment_type(@adapter)
      end

      should "clear the dirty state" do
        @adapter.stubs(:attach_to_nat)
        @instance.save_attachment_type(@adapter)
        assert !@instance.attachment_type_changed?
      end
    end

    context "modifying the adapter" do
      setup do
        @machine = mock("machine")
        @session = mock("session")
        @session.stubs(:machine).returns(@machine)
        @instance.expects(:parent_machine).returns(@parent)

        @adapter = mock("adapter")
      end

      should "open a session, yield the proper adapter, then save settings" do
        seq = sequence("sequence")
        @parent.expects(:with_open_session).yields(@session).in_sequence(seq)
        @machine.expects(:get_network_adapter).with(@instance.slot).returns(@adapter).in_sequence(seq)

        @instance.modify_adapter do |adapter|
          assert_equal @adapter, adapter
        end
      end
    end
  end
end
