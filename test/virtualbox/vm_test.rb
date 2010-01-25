require File.join(File.dirname(__FILE__), '..', 'test_helper')

class VMTest < Test::Unit::TestCase
  setup do
    @raw = <<-showvminfo
VirtualBox Command Line Management Interface Version 3.1.2
(C) 2005-2009 Sun Microsystems, Inc.
All rights reserved.

name="foo"
ostype="Ubuntu"
UUID="8710d3db-d96a-46ed-9004-59fa891fda90"
CfgFile="/Users/mitchellh/Library/VirtualBox/Machines/foo/foo.xml"
hardwareuuid="8710d3db-d96a-46ed-9004-59fa891fda90"
memory=360
vram=12
cpus=1
synthcpu="off"
bootmenu="messageandmenu"
boot1="floppy"
boot2="dvd"
boot3="disk"
boot4="none"
acpi="on"
ioapic="off"
pae="on"
biossystemtimeoffset=0
hwvirtex="on"
hwvirtexexcl="off"
nestedpaging="off"
vtxvpid="off"
VMState="poweroff"
VMStateChangeTime="2010-01-22T22:02:47.672000000"
monitorcount=1
accelerate3d="off"
accelerate2dvideo="off"
teleporterenabled="off"
teleporterport=0
teleporteraddress="<NULL>"
teleporterpassword="<NULL>"
storagecontrollername0="IDE Controller"
storagecontrollertype0="PIIX4"
storagecontrollerinstance0="0"
storagecontrollermaxportcount0="2"
storagecontrollerportcount0="2"
storagecontrollername1="Floppy Controller"
storagecontrollertype1="I82078"
storagecontrollerinstance1="0"
storagecontrollermaxportcount1="1"
storagecontrollerportcount1="1"
"IDE Controller-0-0"="/Users/mitchellh/Library/VirtualBox/HardDisks/HoboBase.vmdk"
"IDE Controller-ImageUUID-0-0"="5e090af6-7d71-4f40-8b03-33aa665f9ecf"
"IDE Controller-0-1"="none"
"IDE Controller-1-0"="emptydrive"
"IDE Controller-1-1"="none"
"Floppy Controller-0-0"="emptydrive"
"Floppy Controller-0-1"="none"
bridgeadapter1="en1: AirPort"
macaddress1="08002771F257"
cableconnected1="on"
nic1="bridged"
nic2="none"
nic3="none"
nic4="none"
nic5="none"
nic6="none"
nic7="none"
nic8="none"
uart1="off"
uart2="off"
audio="none"
clipboard="bidirectional"
vrdp="off"
usb="off"      
showvminfo
    
    @name = "foo"
    
    # Just to be sure nothing is executed
    VirtualBox::Command.stubs(:execute).returns('')
  end
  
  def create_vm
    command_seq = sequence("command_seq")
    VirtualBox::Command.expects(:vboxmanage).with("showvminfo #{@name} --machinereadable").returns(@raw).in_sequence(command_seq)
    VirtualBox::Command.expects(:vboxmanage).with(anything).returns("").at_least(0).in_sequence(command_seq)
    vm = VirtualBox::VM.find(@name)
    assert vm
    vm
  end
  
  context "human readable info" do
    should "not pass --machinereadable into the showvminfo command" do
      VirtualBox::Command.expects(:vboxmanage).with("showvminfo #{@name}").once
      VirtualBox::VM.human_info(@name)
    end
  end
  
  context "reading the VM state" do
    setup do
      @vm = create_vm
    end
    
    should "read the initial state when loading the VM" do
      assert_equal "poweroff", @vm.state
    end
    
    should "reload the state if true is passed as a parameter" do
      VirtualBox::VM.expects(:raw_info).returns({ :vmstate => "on" })
      assert_equal "on", @vm.state(true)
      assert_equal "on", @vm.state
    end
  end
  
  context "controlling a VM (start, stop, pause, etc.)" do
    setup do
      @vm = create_vm
    end
    
    should "start a VM with the given type" do
      VirtualBox::Command.expects(:vboxmanage).with("startvm #{@name} --type FOO")
      @vm.start(:FOO)
    end
    
    should "stop a VM with a 'poweroff'" do
      VirtualBox::Command.expects(:vboxmanage).with("controlvm #{@name} poweroff")
      @vm.stop
    end
    
    should "pause a VM" do
      VirtualBox::Command.expects(:vboxmanage).with("controlvm #{@name} pause")
      @vm.pause
    end
    
    should "resume a VM" do
      VirtualBox::Command.expects(:vboxmanage).with("controlvm #{@name} resume")
      @vm.resume
    end
    
    should "save the state of a VM" do
      VirtualBox::Command.expects(:vboxmanage).with("controlvm #{@name} savestate")
      @vm.save_state
    end
  end
  
  context "destroying" do
    setup do
      @vm = create_vm
    end

    should "destroy all storage controllers before destroying VM" do
      destroy_seq = sequence("destroy_seq")
      VirtualBox::StorageController.expects(:destroy_relationship).in_sequence(destroy_seq)
      VirtualBox::Command.expects(:vboxmanage).with("unregistervm #{@name} --delete").in_sequence(destroy_seq)
      @vm.destroy
    end
  end
  
  context "finding all VMs" do
    setup do
      @raw = <<-raw
"foo" {abcdefg}
"bar"  {zefaldf}
raw
    end
    
    should "list VMs then parse them" do
      all_seq = sequence("all")
      VirtualBox::Command.expects(:vboxmanage).with("list vms").returns(@raw).in_sequence(all_seq)
      VirtualBox::VM.expects(:parse_vm_list).with(@raw).in_sequence(all_seq)
      VirtualBox::VM.all
    end
    
    context "parser" do
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
VirtualBox Command Line Management Interface Version 3.1.2
(C) 2005-2009 Sun Microsystems, Inc.
All rights reserved.

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
      VirtualBox::Command.expects(:vboxmanage).with("import whatever").returns(@raw)
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
    end
    
    should "save only the attributes which saved" do
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm #{@name} --ostype Zubuntu")
      
      @vm.ostype = "Zubuntu"
      @vm.save
    end
    
    should "shell escape saved values" do
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm #{@name} --ostype My\\ Value")
      
      @vm.ostype = "My Value"
      @vm.save
    end
    
    should "shell escape the string value of a value" do
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm #{@name} --memory 400")
      
      @vm.memory = 400
      assert_nothing_raised { @vm.save }
    end
    
    should "save name first if changed, then following values should modify new VM" do
      save_seq = sequence("save_seq")
      new_name = "foo2"
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm #{@name} --name #{new_name}").in_sequence(save_seq)
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm #{new_name} --ostype Zubuntu").in_sequence(save_seq)
      
      @vm.name = new_name
      @vm.ostype = "Zubuntu"
      @vm.save
    end
  end
  
  context "finding a VM by name" do
    setup do

      @expected = {
        :name   => "foo",
        :ostype => "Ubuntu",
        :uuid   => "8710d3db-d96a-46ed-9004-59fa891fda90"
      }
      
      command_seq = sequence("command_seq)")
      VirtualBox::Command.expects(:vboxmanage).with("showvminfo #{@name} --machinereadable").returns(@raw).in_sequence(command_seq)
      VirtualBox::Command.expects(:vboxmanage).with(anything).returns("").at_least(0).in_sequence(command_seq)
      @vm = VirtualBox::VM.find(@name)
      assert @vm
    end
    
    should "return a VM object with proper attributes" do      
      @expected.each do |k,v|
        assert_equal v, @vm.read_attribute(k)
      end
    end
    
    should "properly load nic relationship" do
      assert @vm.nics
      assert @vm.nics.is_a?(Array)
      assert_equal 8, @vm.nics.length
    end
    
    should "properly load storage controller relationship" do
      assert @vm.storage_controllers
      assert @vm.storage_controllers.is_a?(Array)
      assert_equal 2, @vm.storage_controllers.length
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