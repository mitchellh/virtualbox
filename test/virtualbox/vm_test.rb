require File.expand_path("../../test_helper", __FILE__)

class VMTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::VM
    @interface = mock("interface")
    @parent = mock("parent")
  end

  context "class methods" do
    context "retrieving all machines" do
      should "return an array of VM objects" do
        vms = mock("vms")
        global = mock("global")
        global.expects(:vms).returns(vms)
        VirtualBox::Global.expects(:global).returns(global)
        assert_equal vms, VirtualBox::VM.all
      end
    end

    context "finding a VM" do
      setup do
        @all = []
        @klass.stubs(:all).returns(@all)
      end

      def mock_vm(uuid, name=nil)
        vm = mock("vm-#{uuid}")
        vm.stubs(:uuid).returns(uuid)
        vm.stubs(:name).returns(name)
        vm
      end

      should "return nil if it doesn't exist" do
        @all << mock_vm("foo")
        assert_nil @klass.find("bar")
      end

      should "return the matching vm if it is found" do
        vm = mock_vm("foo")
        @all << mock_vm("bar")
        @all << vm
        assert_equal vm, @klass.find("foo")
      end

      should "return if matching name is found" do
        vm = mock_vm(nil, "foo")
        @all << vm
        assert_equal vm, @klass.find("foo")
      end
    end

    context "importing" do
      setup do
        @path = "foo.rb"
        @appliance = mock("appliance")
        @virtual_system = mock("virtual_system")
        @appliance.stubs(:virtual_systems).returns([@virtual_system])

        @name = :foo
        @virtual_system.stubs(:descriptions).returns({
          :name => { :auto => @name }
        })
      end

      should "create a new appliance with path, import, and return VM" do
        result = mock("result")
        proc = mock("proc")
        VirtualBox::Appliance.expects(:new).with(@path).returns(@appliance)
        @appliance.expects(:import).yields(proc)
        @klass.expects(:find).with(@name).returns(result)
        proc.expects(:call)

        value = @klass.import(@path) do |proc|
          proc.call
        end

        assert_equal result, value
      end
    end

    context "populating relationships" do
      setup do
        @caller = mock("caller")
      end

      should "call populate_array_relationship for arrays" do
        @klass.expects(:populate_array_relationship).with(@caller, []).once
        @klass.populate_relationship(@caller, [])
      end

      should "call populate_single_relationship for non-arrays" do
        @klass.expects(:populate_single_relationship).with(@caller, nil).once
        @klass.populate_relationship(@caller, nil)
      end
    end

    context "populating single relationships" do
      setup do
        @machine = mock("interface")
      end

      should "return a new machine" do
        result = mock("result")
        @klass.expects(:new).with(@machine).returns(result)
        assert_equal result, @klass.populate_single_relationship(nil, @machine)
      end
    end

    context "populating array relationship" do
      setup do
        @instance = mock("instance")

        @klass.stubs(:new).returns(@instance)
      end

      should "return a proxied collection" do
        result = @klass.populate_array_relationship(nil, [])
        assert result.is_a?(VirtualBox::Proxies::Collection)
      end

      should "call new for every machine" do
        machines = []
        5.times { |i| machines << mock("m#{i}") }

        expected_result = []
        new_seq = sequence("new_seq")
        machines.each do |machine|
          expected_value = "instance-#{machine.inspect}"
          @klass.expects(:new).with(machine).in_sequence(new_seq).returns(expected_value)
          expected_result << expected_value
        end

        assert_equal expected_result, @klass.populate_array_relationship(nil, machines)
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
      @klass.any_instance.stubs(:populate_relationships)
    end

    should "load interface attribtues" do
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once
      @klass.new(@interface)
    end

    should "populate relationships" do
      @klass.any_instance.expects(:populate_relationships).with(@interface).once
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
      @instance = @klass.new(@interface)
    end

    def setup_session_mocks
      @parent = mock("parent")
      @session = mock("session")
      @lib = mock("lib")
      @progress = mock("progress")

      @session.stubs(:close)
      @progress.stubs(:wait_for_completion)
      @lib.stubs(:session).returns(@session)
      @uuid = :foo

      VirtualBox::Lib.stubs(:lib).returns(@lib)
      @interface.stubs(:parent).returns(@parent)
      @instance.stubs(:imachine).returns(@interface)
      @instance.stubs(:uuid).returns(@uuid)
      @instance.stubs(:running).returns(false)
    end

    context "reloading" do
      setup do
        @instance.stubs(:initialize_attributes)
      end

      should "just reload the attributes" do
        @instance.expects(:initialize_attributes).with(@interface).once
        @instance.reload
      end

      should "return itself" do
        assert @instance.equal?(@instance.reload)
      end
    end

    context "destroying" do
      setup do
        @instance.stubs(:uuid).returns(:foo)

        @interface_parent = mock("interface_parent")
        @interface.stubs(:parent).returns(@interface_parent)
      end

      should "do a full destroy and destroy the media" do
        destroy_seq = sequence("destroy_seq")
        media = [1,2,3]
        progress = mock("progress")
        @interface.expects(:unregister).with(:full).once.returns(media).in_sequence(destroy_seq)
        @interface.expects(:delete).with(media).once.returns(progress).in_sequence(destroy_seq)

        @instance.destroy
      end

      should "not destroy media if there aren't any" do
        @interface.expects(:unregister).with(:full).once.returns([])
        @interface.expects(:delete).never

        @instance.destroy
      end
    end

    context "state" do
      setup do
        @state = mock("state")
        @interface = mock("interface")
        @instance.stubs(:read_attribute).with(:state).returns(@state)
        @instance.stubs(:interface).returns(@interface)
      end

      should "reload and return the state" do
        @instance.expects(:load_interface_attribute).with(:state, @instance.interface).once
        assert_equal @state, @instance.state
      end

      should "not reload the state if suppress is given" do
        @instance.expects(:load_interface_attribute).never
        assert_equal @state, @instance.state(true)
      end
    end

    context "starting" do
      setup do
        setup_session_mocks

        @instance.stubs(:running?).returns(false)
        @session.stubs(:state).returns(:open)
      end

      should "launch the VM with the given mode" do
        start_seq = sequence('start_seq')
        mode = "foo"
        @interface.expects(:launch_vm_process).with(@session, mode, "").once.returns(@progress).in_sequence(start_seq)
        @progress.expects(:wait).in_sequence(start_seq)
        @session.expects(:unlock_machine).in_sequence(start_seq)
        assert @instance.start(mode)
      end

      should "return false if state is running" do
        @instance.expects(:running?).returns(true)
        assert !@instance.start(nil)
      end
    end

    context "controlling" do
      setup do
        setup_session_mocks

        @console = mock("console")
        @console.stubs(:send)
        @session.stubs(:console).returns(@console)
        @session.stubs(:state).returns(:open)

        @instance.stubs(:with_open_session).yields(@session)

        @method = :foo
      end

      should "get an existing, session, send the command, and close" do
        method = :foo
        control_seq = sequence("control_seq")
        @instance.expects(:with_open_session).with(:shared).yields(@session).in_sequence(control_seq)
        @console.expects(:send).with(@method).once.in_sequence(control_seq)

        @instance.control(@method)
      end

      should "wait for completion if an IProgress is returned" do
        progress = mock("IProgress")
        progress.stubs(:is_a?).with(VirtualBox::COM::Util.versioned_interface(:Progress)).returns(true)
        progress.expects(:wait).once
        @console.expects(:send).with(@method).returns(progress)
        @instance.control(@method)
      end

      should "forward other args" do
        @console.expects(:send).with(@method, 1, 2, 3).once
        @instance.control(@method, 1, 2, 3)
      end
    end

    context "control helpers" do
      should "call the proper control method" do
        methods = {
          :shutdown => :power_button,
          :stop => :power_down,
          :pause => :pause,
          :resume => :resume,
          :save_state => :save_state
        }

        methods.each do |method, control|
          control = [control] unless control.is_a?(Array)
          @instance.expects(:control).with(*control).once
          @instance.send(method)
        end
      end

      context "discard state" do
        setup do
          @session = mock("session")
          @console = mock("console")
          @session.stubs(:console).returns(@console)
          @instance.stubs(:with_open_session)
        end

        should "discard the session in an open state" do
          @instance.expects(:with_open_session).yields(@session)
          @console.expects(:forget_saved_state).with(true).once
          @instance.discard_state
        end
      end
    end

    context "saving" do
      setup do
        @session = mock("session")
        @session.stubs(:machine).returns(@parent)

        @locked_interface = mock("locked_interface")

        @instance.stubs(:saved?).returns(false)
        @instance.stubs(:valid?).returns(true)
        @instance.stubs(:with_open_session)
      end

      should "open the session, save, and close" do
        save_seq = sequence("save_seq")
        @instance.expects(:with_open_session).once.yields(@session).in_sequence(save_seq)
        @session.expects(:machine).returns(@locked_interface).in_sequence(save_seq)
        @instance.expects(:save_interface_attribute).with(:boot_order, @locked_interface).in_sequence(save_seq)
        @instance.expects(:save_changed_interface_attributes).with(@locked_interface).in_sequence(save_seq)
        @instance.expects(:save_relationships).in_sequence(save_seq)

        @instance.save
      end

      should "raise an exception if saved" do
        @instance.stubs(:saved?).returns(true)

        assert_raises(VirtualBox::Exceptions::ReadonlyVMStateException) {
          @instance.save
        }
      end

      should "return false if not valid" do
        @instance.stubs(:valid?).returns(false)
        assert !@instance.save
      end

      should "return true if save succeeds" do
        assert @instance.save
      end
    end

    context "opening a session [direct]" do
      setup do
        setup_session_mocks

        @locked_interface = mock("locked_interface")
        @locked_interface.stubs(:state).returns(:powered_off)
        @session.stubs(:machine).returns(@locked_interface)
        @session.stubs(:state).returns(:closed)
        @interface.stubs(:lock_machine)
      end

      should "close the session if an exception is raised" do
        @locked_interface.expects(:save_settings).raises(Exception)
        @session.expects(:unlock_machine).once

        assert_raises(Exception) do
          @instance.with_open_session do
            # After this point, state should be open
            @session.stubs(:state).returns(:open)
          end
        end
      end

      should "open the session, save, and close" do
        save_seq = sequence("save_seq")
        @proc = Proc.new {}

        @interface.expects(:lock_machine).with(@session, :write).in_sequence(save_seq)
        @proc.expects(:call).with(@session).once.in_sequence(save_seq)
        @locked_interface.expects(:save_settings).once.in_sequence(save_seq)
        @session.expects(:unlock_machine).in_sequence(save_seq)

        @instance.with_open_session do |session|
          @proc.call(session)
        end
      end

      should "open the session with the shared type and NOT save settings" do
        @interface.expects(:lock_machine).with(@session, :shared)
        @session.expects(:unlock_machine)
        @locked_interface.expects(:save_settings).never

        @instance.with_open_session(:shared)
      end

      should "not save settings when the state is saved" do
        @locked_interface.stubs(:state).returns(:saved)

        save_seq = sequence("save_seq")
        @interface.expects(:lock_machine).with(@session, :write).in_sequence(save_seq)
        @locked_interface.expects(:save_settings).never
        @session.expects(:unlock_machine).in_sequence(save_seq)

        @instance.with_open_session { |session| }
      end

      should "only open the session and close once" do
        open_seq = sequence("open_seq")

        @interface.expects(:lock_machine).with(@session, :write).in_sequence(open_seq)
        @locked_interface.expects(:save_settings).once.in_sequence(open_seq)
        @session.expects(:unlock_machine).once.in_sequence(open_seq)

        @instance.with_open_session do |session|
          session.stubs(:state).returns(:open)

          @instance.with_open_session do |subsession|
            assert_equal session, subsession
          end
        end
      end
    end

    context "state methods" do
      should "check the proper results" do
        methods = {
          :starting? => :starting,
          :running? => :running,
          :powered_off? => :powered_off,
          :paused? => :paused,
          :saved? => :saved,
          :aborted? => :aborted
        }

        methods.each do |method, value|
          @instance.stubs(:state).returns(value)
          assert @instance.send(method)

          @instance.stubs(:state).returns(:nope)
          assert !@instance.send(method)
        end
      end
    end

    context "exporting" do
      setup do
        @path = "foo.rb"
        @appliance = mock("appliance")
        @appliance.stubs(:path=)
        @appliance.stubs(:add_machine)

        VirtualBox::Appliance.stubs(:new).returns(@appliance)
      end

      should "create a new appliance with path and export" do
        result = mock("result")
        options = mock("options")
        VirtualBox::Appliance.expects(:new).returns(@appliance)
        @appliance.expects(:path=).with(@path)
        @appliance.expects(:add_machine).with(@instance, options)
        @appliance.expects(:export)

        @instance.export(@path, options)
      end

      should "forward any block to the appliance export method" do
        proc = mock("proc")
        @appliance.expects(:export).yields(proc)
        proc.expects(:call)

        @instance.export(@path) do |yielded_proc|
          yielded_proc.call
        end
      end
    end

    context "taking a snapshot" do
      setup do
        setup_session_mocks

        @progress = mock("progress")
        @progress.stubs(:wait)

        @console = mock("console")
        @console.stubs(:take_snapshot).returns(@progress)
        @session.stubs(:console).returns(@console)

        @instance.stubs(:with_open_session).yields(@session)
      end

      should "take a snapshot on the console and wait" do
        name = "foo"
        description = "baz"
        @console.expects(:take_snapshot).with(name, description).returns(@progress)
        @instance.take_snapshot(name, description)
      end

      should "wait and pass in the given block, if given" do
        foo = mock("foo")
        @progress.expects(:wait).yields(foo)
        foo.expects(:called).once

        @instance.take_snapshot(nil, nil) do |obj|
          obj.called
        end
      end
    end

    context "root snapshot" do
      should "return nil if the current snapshot is nil" do
        @instance.stubs(:current_snapshot).returns(nil)
        assert_nil @instance.root_snapshot
      end

      should "return the proper root snapshot" do
        root = mock("root_snapshot")
        root.stubs(:parent).returns(nil)

        parent = mock("parent")
        parent.stubs(:parent).returns(root)

        snapshot = mock("snapshot")
        snapshot.stubs(:parent).returns(parent)

        @instance.stubs(:current_snapshot).returns(snapshot)
        assert_equal root, @instance.root_snapshot
      end
    end

    context "finding a snapshot" do
      should "return nil if there is no root snapshot" do
        @instance.stubs(:current_snapshot).returns(nil)
        assert_nil @instance.find_snapshot("foo")
      end

      should "return nil if the snapshot is not found" do
        snapshot = mock("snapshot")
        snapshot.stubs(:name).returns("wrong")
        snapshot.stubs(:uuid).returns(nil)
        snapshot.stubs(:children).returns([])
        @instance.stubs(:root_snapshot).returns(snapshot)

        assert_nil @instance.find_snapshot("bar")
      end

      # TODO: Testing traversing the snapshot tree. Too many mocks :S
    end

    context "getting the boot order" do
      setup do
        @max = 4
        @global = mock("global")
        @sys_props = mock("system_properties")

        @sys_props.stubs(:max_boot_position).returns(@max)
        @global.stubs(:system_properties).returns(@sys_props)
        VirtualBox::Global.stubs(:global).returns(@global)
      end

      should "get the boot order for each up to max" do
        expected = (1..@max).inject([]) do |acc, pos|
          result = mock("p#{pos}")
          @interface.expects(:get_boot_order).with(pos).returns(result)
          acc << result
          acc
        end

        assert_equal expected, @instance.get_boot_order(@interface, nil)
      end
    end

    context "setting the boot order" do
      setup do
        @max = 4
        @global = mock("global")
        @sys_props = mock("system_properties")

        @sys_props.stubs(:max_boot_position).returns(@max)
        @global.stubs(:system_properties).returns(@sys_props)
        VirtualBox::Global.stubs(:global).returns(@global)
      end

      should "set the boot order for each up to max" do
        expected = (1..@max).inject([]) do |acc, pos|
          result = mock("p#{pos}")
          @interface.expects(:set_boot_order).with(pos, result)
          acc << result
          acc
        end

        @instance.set_boot_order(@interface, nil, expected)
      end

      should "set the boot order for max items even if value has less than the proper amount" do
        items = [1, 2]
        items.concat(Array.new(@max - items.size))
        items.each_with_index do |item, i|
          @interface.expects(:set_boot_order).with(i + 1, item).once
        end

        assert_equal @max, items.size # sanity

        @instance.set_boot_order(@interface, nil, items)
      end
    end
  end
end
