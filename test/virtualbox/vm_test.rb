require File.join(File.dirname(__FILE__), '..', 'test_helper')

class VMTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::VM
    @interface = mock("interface")
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

    context "populating relationship" do
      setup do
        @instance = mock("instance")

        @klass.stubs(:new).returns(@instance)
      end

      should "return a proxied collection" do
        result = @klass.populate_relationship(nil, [])
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

        assert_equal expected_result, @klass.populate_relationship(nil, machines)
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

    context "destroying" do
      setup do
        @instance.stubs(:uuid).returns(:foo)

        @interface_parent = mock("interface_parent")
        @interface.stubs(:parent).returns(@interface_parent)
      end

      should "destroy relationships first, then the machine" do
        destroy_seq = sequence("destroy_seq")
        VirtualBox::StorageController.expects(:destroy_relationship).in_sequence(destroy_seq)
        @interface_parent.expects(:unregister_machine).with(@instance.uuid).in_sequence(destroy_seq)
        @interface.expects(:delete_settings).once.in_sequence(destroy_seq)

        @instance.destroy
      end
    end

    context "state" do
      setup do
        @state = mock("state")
        @instance.stubs(:read_attribute).with(:state).returns(@state)
      end

      should "just return the state" do
        assert_equal @state, @instance.state
      end

      should "reload the state if reload is set" do
        @instance.expects(:load_interface_attribute).with(:state).once
        assert_equal @state, @instance.state(true)
      end
    end

    context "starting" do
      setup do
        setup_session_mocks
      end

      should "open remote session using the given mode, wait for completion, then close" do
        start_seq = sequence('start_seq')
        mode = "foo"
        @parent.expects(:open_remote_session).with(@session, @uuid, mode, "").once.returns(@progress).in_sequence(start_seq)
        @progress.expects(:wait_for_completion).with(-1).in_sequence(start_seq)
        @session.expects(:close).in_sequence(start_seq)
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

        @parent.stubs(:open_existing_session)

        @console = mock("console")
        @console.stubs(:send)
        @session.stubs(:console).returns(@console)

        @method = :foo
      end

      should "get an existing, session, send the command, and close" do
        method = :foo
        control_seq = sequence("control_seq")
        @parent.expects(:open_existing_session).with(@session, @uuid).once.in_sequence(control_seq)
        @console.expects(:send).with(@method).once.in_sequence(control_seq)
        @session.expects(:close).in_sequence(control_seq)

        @instance.control(@method)
      end

      should "wait for completion if an IProgress is returned" do
        progress = mock("IProgress")
        progress.stubs(:is_a?).with(VirtualBox::COM::Interface::Progress).returns(true)
        progress.expects(:wait_for_completion).with(-1).once
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
          :save_state => :save_state,
          :discard_state => [:forget_saved_state, true]
        }

        methods.each do |method, control|
          control = [control] unless control.is_a?(Array)
          @instance.expects(:control).with(*control).once
          @instance.send(method)
        end
      end
    end

    context "saving" do
      setup do
        @session = mock("session")
        @session.stubs(:machine).returns(@parent)

        @locked_interface = mock("locked_interface")
      end

      should "open the session, save, and close" do
        save_seq = sequence("save_seq")
        @instance.expects(:with_open_session).once.yields(@session).in_sequence(save_seq)
        @session.expects(:machine).returns(@locked_interface).in_sequence(save_seq)
        @instance.expects(:save_changed_interface_attributes).with(@locked_interface).in_sequence(save_seq)
        @instance.expects(:save_relationships).in_sequence(save_seq)

        @instance.save
      end
    end

    context "opening a session [direct]" do
      setup do
        setup_session_mocks

        @locked_interface = mock("locked_interface")
        @session.stubs(:machine).returns(@locked_interface)
        @session.stubs(:state).returns(:closed)
      end

      should "open the session, save, and close" do
        save_seq = sequence("save_seq")
        @proc = Proc.new {}

        @parent.expects(:open_session).with(@session, @uuid).in_sequence(save_seq)
        @proc.expects(:call).with(@session).once.in_sequence(save_seq)
        @locked_interface.expects(:save_settings).once.in_sequence(save_seq)
        @session.expects(:close).in_sequence(save_seq)

        @instance.with_open_session do |session|
          @proc.call(session)
        end
      end

      should "only open the session and close once" do
        open_seq = sequence("open_seq")

        @parent.expects(:open_session).with(@session, @uuid).in_sequence(open_seq)
        @locked_interface.expects(:save_settings).once.in_sequence(open_seq)
        @session.expects(:close).once.in_sequence(open_seq)

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
  end
end