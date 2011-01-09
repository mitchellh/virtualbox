require File.expand_path("../../test_helper", __FILE__)

class ApplianceTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::Appliance
    @interface = mock("interface")
    @parent = mock("parent")
    @path = "foo.rb"

    @appliance = mock("appliance")
    @virtualbox = mock("virtualbox")
    @lib = mock("lib")
    VirtualBox::Lib.stubs(:lib).returns(@lib)
    @lib.stubs(:virtualbox).returns(@virtualbox)
    @virtualbox.stubs(:create_appliance).returns(@appliance)
  end

  context "class methods" do

  end

  context "initializing" do
    should "load interface attribtues" do
      @klass.any_instance.expects(:initialize_from_path).with(@path).once
      @klass.new(@path)
    end

    context "initializing from path" do
      setup do
        @progress = mock("progress")
        @appliance.stubs(:read).returns(@progress)
        @appliance.stubs(:interpret)
        @appliance.stubs(:virtual_system_descriptions)
        @progress.stubs(:wait_for_completion)

        @klass.any_instance.stubs(:populate_relationship)
        @klass.any_instance.stubs(:load_interface_attributes)
      end

      should "write the interface as the appliance" do
        instance = @klass.new(@path)
        assert_equal @appliance, instance.interface
      end

      should "mark as an existing record" do
        instance = @klass.new(@path)
        assert !instance.new_record?
      end

      should "read the appliance then interpret it" do
        init_seq = sequence("init")
        @appliance.expects(:read).with(@path).once.returns(@progress).in_sequence(init_seq)
        @progress.expects(:wait_for_completion).with(-1).in_sequence(init_seq)
        @appliance.expects(:interpret).once.in_sequence(init_seq)
        @klass.any_instance.expects(:load_interface_attributes).with(@appliance).once.in_sequence(init_seq)

        @klass.new(@path)
      end
    end

    context "initialize without path" do
      setup do
        @instance = @klass.new
      end

      should "write the interface as the appliance" do
        assert_equal @appliance, @instance.interface
      end

      should "be new record" do
        assert @instance.new_record?
      end

      should "not be dirty" do
        assert !@instance.changed?
      end
    end
  end

  context "instance methods" do
    setup do
      @klass.any_instance.stubs(:initialize_from_path)
      @instance = @klass.new(@path)
      @instance.stubs(:interface).returns(@interface)
    end

    context "importing" do
      setup do
        @progress = mock("progress")

        @interface.stubs(:import_machines).returns(@progress)
      end

      should "call import on interface and wait for completion" do
        @interface.expects(:import_machines).returns(@progress)
        @progress.expects(:wait)

        @instance.import
      end

      should "call wait with block given" do
        proc = mock("proc")
        @progress.expects(:wait).yields(proc)
        proc.expects(:call)

        @instance.import do |proc|
          proc.call
        end
      end
    end

    context "exporting" do
      setup do
        @progress = mock("progress")

        @instance.path = :foo
        @interface.stubs(:write).returns(@progress)
      end

      should "call write on interface and wait for completion" do
        @interface.expects(:write).with("ovf-1.0", true, @instance.path).once.returns(@progress)
        @progress.expects(:wait)

        @instance.export
      end

      should "call wait with block given" do
        proc = mock("proc")
        @progress.expects(:wait).yields(proc)
        proc.expects(:call)

        @instance.export do |proc|
          proc.call
        end
      end
    end

    context "adding a machine" do
      setup do
        @machine = mock("machine")
        @machine_interface = mock("machine_interface")
        @machine.stubs(:interface).returns(@machine_interface)
        @machine_interface.stubs(:export)
      end

      should "call export on the VM interface with the appliance" do
        @machine_interface.expects(:export).with(@interface, @instance.path).once
        @instance.add_machine(@machine)
      end

      should "add to the description for each option given" do
        sys = mock("sys")
        @machine_interface.expects(:export).with(@interface, @instance.path).once.returns(sys)
        sys.expects(:add_description).with(:foo, :bar, :bar)
        @instance.add_machine(@machine, { :foo => :bar })
      end
    end
  end
end
