require File.join(File.dirname(__FILE__), '..', 'test_helper')

class VMTest < Test::Unit::TestCase
  setup do
    @raw_xml = mock_xml
    @raw_xml_doc = mock_xml_doc

    @name = "foo"

    # Just to be sure nothing is executed
    VirtualBox::Command.stubs(:execute).returns('')
  end

  def create_vm
    VirtualBox::Command.expects(:parse_xml).returns(@raw_xml_doc)
    vm = VirtualBox::VM.load_from_xml(@name)
    assert vm
    vm
  end

  context "reading the VM state" do
    setup do
      @vm = create_vm
    end

    should "lazy load the state" do
      @vm.expects(:load_attribute).with(:state).once
      @vm.state
    end

    should "reload the state if true is passed as a parameter" do
      VirtualBox::VM.expects(:raw_info).returns({ :vmstate => "on" })
      assert_equal "on", @vm.state(true)
      assert_equal "on", @vm.state
    end

    should "provide conveniance methods for determining VM state" do
      VirtualBox::VM.expects(:raw_info).returns({ :vmstate => "poweroff" })
      assert_equal "poweroff", @vm.state(true)
      assert @vm.powered_off?

      VirtualBox::VM.expects(:raw_info).returns({ :vmstate => "running" })
      assert_equal "running", @vm.state(true)
      assert @vm.running?

      VirtualBox::VM.expects(:raw_info).returns({ :vmstate => "paused" })
      assert_equal "paused", @vm.state(true)
      assert @vm.paused?

      VirtualBox::VM.expects(:raw_info).returns({ :vmstate => "saved" })
      assert_equal "saved", @vm.state(true)
      assert @vm.saved?

      VirtualBox::VM.expects(:raw_info).returns({ :vmstate => "aborted" })
      assert_equal "aborted", @vm.state(true)
      assert @vm.aborted?
    end
  end

  context "exporting a VM" do
    setup do
      @vm = create_vm
    end

    should "export the VM with no options if none are passed" do
      VirtualBox::Command.expects(:vboxmanage).with("export", @name, "-o", "foo")
      @vm.export("foo")
    end

    should "export the VM with specified options" do
      VirtualBox::Command.expects(:vboxmanage).with("export", @name, "-o", "foo", "--vsys", "0", "--foo", :bar)
      @vm.export("foo", :foo => :bar)
    end

    should "shell escape all the options" do
      VirtualBox::Command.expects(:vboxmanage).with("export", @name, "-o", "foo", "--vsys", "0", "--foo", "a space")
      @vm.export("foo", :foo => "a space")
    end

    should "return true if the export succeeded" do
      VirtualBox::Command.expects(:vboxmanage).once
      assert @vm.export("foo")
    end

    should "return false if the export failed" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert !@vm.export("foo")
    end

    should "raise an exception on failure if raise_error is true" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @vm.export("foo", {}, true)
      }
    end
  end

  context "controlling a VM (start, stop, pause, etc.)" do
    setup do
      @vm = create_vm
    end

    context "control method" do
      should "run the given command when 'control' is called" do
        VirtualBox::Command.expects(:vboxmanage).with("controlvm", @name, :foo)
        assert @vm.control(:foo)
      end

      should "return false if the command failed" do
        VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
        assert !@vm.control(:foo)
      end

      should "raise an exception if flag is set" do
        VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
        assert_raises(VirtualBox::Exceptions::CommandFailedException) {
          @vm.control(:foo, true)
        }
      end
    end

    should "start a VM with the given type" do
      VirtualBox::Command.expects(:vboxmanage).with("startvm", @name, "--type", :FOO)
      assert @vm.start(:FOO)
    end

    should "return false if start failed" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert !@vm.start
    end

    should "raise an exception if start fails and flag is set" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @vm.start(:foo, true)
      }
    end

    should "stop a VM with a 'acpipowerbutton'" do
      @vm.expects(:control).with(:acpipowerbutton, false).returns(true)
      assert @vm.shutdown
    end

    should "stop a VM with a 'poweroff'" do
      @vm.expects(:control).with(:poweroff, false).returns(true)
      assert @vm.stop
    end

    should "pause a VM" do
      @vm.expects(:control).with(:pause, false).returns(true)
      assert @vm.pause
    end

    should "resume a VM" do
      @vm.expects(:control).with(:resume, false).returns(true)
      assert @vm.resume
    end

    should "save the state of a VM" do
      @vm.expects(:control).with(:savestate, false).returns(true)
      assert @vm.save_state
    end

    should "discard a saved state of a VM" do
      VirtualBox::Command.expects(:vboxmanage).with("discardstate", @name)
      assert @vm.discard_state
    end

    should "return false if discarding state failed" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert !@vm.discard_state
    end

    should "raise an exception if discarding state fails and flag is set" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @vm.discard_state(true)
      }
    end
  end

  context "destroying" do
    setup do
      @vm = create_vm
    end

    should "destroy all storage controllers before destroying VM" do
      destroy_seq = sequence("destroy_seq")
      VirtualBox::StorageController.expects(:destroy_relationship).in_sequence(destroy_seq)
      VirtualBox::Command.expects(:vboxmanage).with("unregistervm", @name, "--delete").in_sequence(destroy_seq)
      @vm.destroy
    end
  end

  context "finding all VMs" do
    should "list VMs then parse them" do
      global = mock("global")
      global.expects(:vms).once
      VirtualBox::Global.expects(:global).with(false).returns(global)
      VirtualBox::VM.all
    end

    should "reload the VMs list if given the reload argument" do
      global = mock("global")
      global.expects(:vms).once
      VirtualBox::Global.expects(:global).with(true).returns(global)
      VirtualBox::VM.all(true)
    end

    context "parser" do
      setup do
      @raw = <<-raw
"foo" {abcdefg}
"bar"  {zefaldf}
raw
      end

      should "ignore non-matching lines" do
        assert VirtualBox::VM.parse_vm_list("HEY YOU").empty?
      end

      should "return VM objects for valid lines" do
        vm_foo = mock("vm_foo")
        vm_bar = mock("vm_bar")
        parse_seq = sequence("parse")
        VirtualBox::VM.expects(:find).with("foo").returns(vm_foo).in_sequence(parse_seq)
        VirtualBox::VM.expects(:find).with("bar").returns(vm_bar).in_sequence(parse_seq)

        result = VirtualBox::VM.parse_vm_list(@raw)
        assert !result.empty?
        assert_equal 2, result.length
        assert_equal vm_foo, result[0]
        assert_equal vm_bar, result[1]
      end
    end
  end

  context "importing a VM" do
    setup do
      @raw = <<-raw
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
Interpreting /Users/mitchellh/base.ovf...
OK.
Disks:  vmdisk1 21474836480     -1      http://www.vmware.com/specifications/vmdk.html#sparse   HoboBase.vmdk   379268096 -1       <NULL>
Virtual system 0:
 0: Suggested OS type: "Ubuntu"
    (change with "--vsys 0 --ostype <type>"; use "list ostypes" to list all possible values)
 1: Suggested VM name "Base_1"
    (change with "--vsys 0 --vmname <name>")
 2: Number of CPUs: 1
raw
    end

    should "attempt to find the imported VM" do
      VirtualBox::Command.expects(:vboxmanage).with("import", "whatever").returns(@raw)
      VirtualBox::VM.expects(:find).with("Base_1").once
      VirtualBox::VM.import("whatever")
    end

    should "parse the VM name from the raw string" do
      assert_equal "Base_1", VirtualBox::VM.parse_vm_name(@raw)
    end

    should "return nil on parsing the VM name if its invalid" do
      assert_nil VirtualBox::VM.parse_vm_name("Name foo")
    end
  end

  context "saving a changed VM" do
    setup do
      @vm = create_vm
      VirtualBox::AttachedDevice.any_instance.stubs(:save)
    end

    should "return false if saving fails" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)

      @vm.ostype = "Zubuntu"
      assert !@vm.save
    end

    should "raise an error if saving fails and flag to true" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)

      @vm.ostype = "Zubuntu"
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @vm.save(true)
      }
    end

    should "save only the attributes which saved" do
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm", @name, "--ostype", "Zubuntu")

      @vm.ostype = "Zubuntu"
      assert @vm.save
    end

    should "save name first if changed, then following values should modify new VM" do
      save_seq = sequence("save_seq")
      new_name = "foo2"
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm", @name, "--name", new_name).in_sequence(save_seq)
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm", new_name, "--ostype", "Zubuntu").in_sequence(save_seq)

      @vm.name = new_name
      @vm.ostype = "Zubuntu"
      assert @vm.save
    end

    should "save the relationships as well" do
      VirtualBox::Nic.expects(:save_relationship).once
      VirtualBox::StorageController.expects(:save_relationship).once
      VirtualBox::SharedFolder.expects(:save_relationship).once
      VirtualBox::ExtraData.expects(:save_relationship).once
      VirtualBox::ForwardedPort.expects(:save_relationship).once
      assert @vm.save
    end
  end

  context "loading a VM from XML" do
    should "parse the XML then initializing the class" do
      VirtualBox::Command.expects(:parse_xml).with("foo").returns(@raw_xml_doc)
      VirtualBox::VM.expects(:new).with(@raw_xml_doc).once
      VirtualBox::VM.load_from_xml("foo")
    end

    should "initialize the attributes when called with an XML document" do
      VirtualBox::VM.any_instance.expects(:initialize_attributes).once.with(@raw_xml_doc)
      VirtualBox::VM.new(@raw_xml_doc)
    end
  end

  context "initializing attributes" do
    # TODO: This needs to be tested
  end

  context "finding a VM by name" do
    setup do
      @expected = {
        :name   => "foo",
        :ostype => "Ubuntu",
        :uuid   => "8710d3db-d96a-46ed-9004-59fa891fda90"
      }
    end

    should "use the global 'all' array to find the VM" do
      VirtualBox::VM.expects(:all).with(true).returns([create_vm])
      vm = VirtualBox::VM.find(@name)
      assert vm

      @expected.each do |k,v|
        assert_equal v, vm.read_attribute(k)
      end
    end

    should "return nil if the VM doesn't exist" do
      VirtualBox::VM.expects(:all).returns([])
      assert_nil VirtualBox::VM.find("dont exist")
    end
  end

  context "parsing the showvminfo output" do
    should "lowercase and symbolize the keys" do
      result = VirtualBox::VM.parse_vm_info("ZING=Zam")
      assert_equal 1, result.length
      assert_equal "Zam", result[:zing]
    end

    should "ignore quotes for multi-word keys or values" do
      result = VirtualBox::VM.parse_vm_info('"foo bar"="baz"')
      assert_equal 1, result.length
      assert_equal "baz", result[:"foo bar"]
    end

    should "ignore the lines which aren't the proper format" do
      result = VirtualBox::VM.parse_vm_info(<<-block)
This should not be parsed
Neither should this

foo=bar
block

      assert_equal 1, result.length
      assert_equal "bar", result[:foo]
    end
  end
end