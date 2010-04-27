require File.join(File.dirname(__FILE__), '..', 'test_helper')

class SnapshotTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::Snapshot
    @interface = mock("isnapshot")
  end

  context "class methods" do
    context "populating relationships" do
      setup do
        @caller = mock("caller")
      end

      should "call populate_machine_relationship for VMs" do
        vm = mock("vm")
        vm.stubs(:is_a?).with(VirtualBox::COM::Interface::Machine).returns(true)
        @klass.expects(:populate_machine_relationship).with(@caller, vm).once
        @klass.populate_relationship(@caller, vm)
      end
    end

    context "populating machine relationship" do
      setup do
        @caller = mock("caller")
        @machine = mock("imachine")
        @snapshot = mock("snapshot")
        @machine.stubs(:current_snapshot).returns(@snapshot)
      end

      should "just initialize with machine" do
        result = mock("result")
        @klass.expects(:new).with(@snapshot).once.returns(result)
        assert_equal result, @klass.populate_machine_relationship(@caller, @machine)
      end

      should "return nil if there is no current snapshot" do
        @machine.expects(:current_snapshot).returns(nil)
        assert_nil @klass.populate_machine_relationship(@caller, @machine)
      end
    end
  end

  context "initializing" do
    should "load attributes from the snapshot" do
      @klass.any_instance.expects(:initialize_attributes).with(@interface).once
      @klass.new(@interface)
    end

    should "set the interface as the interface attribute" do
      @klass.any_instance.stubs(:initialize_attributes)
      instance = @klass.new(@interface)
      assert_equal @interface, instance.interface
    end
  end

  context "initializing attributes" do
    setup do
      @interface.stubs(:refresh_state)
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

  context "with an instance" do
    setup do
      @klass.any_instance.stubs(:initialize_attributes)
      @instance = @klass.new(@interface)
    end
  end
end