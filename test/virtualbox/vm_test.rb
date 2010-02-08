require File.join(File.dirname(__FILE__), '..', 'test_helper')

class VMTest < Test::Unit::TestCase
  setup do
    @raw = <<-showvminfo
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
SharedFolderNameMachineMapping1="mysharedfolder"
SharedFolderPathMachineMapping1="/virtualbox"
SharedFolderNameMachineMapping2="otherfolder"
SharedFolderPathMachineMapping2="/virtualbox/lib"
showvminfo

    @raw_xml = <<-xml
<?xml version="1.0"?>
<VirtualBox xmlns="http://www.innotek.de/VirtualBox-settings" version="1.9-macosx">
  <Machine uuid="{8710d3db-d96a-46ed-9004-59fa891fda90}" name="foo" OSType="Ubuntu" currentSnapshot="{f1e6edb3-6e12-4615-9642-a80a3a1ad115}" lastStateChange="2010-02-07T20:01:20Z">
    <ExtraData>
      <ExtraDataItem name="GUI/AutoresizeGuest" value="on"/>
      <ExtraDataItem name="GUI/Fullscreen" value="off"/>
      <ExtraDataItem name="GUI/LastWindowPostion" value="1040,171,720,422"/>
      <ExtraDataItem name="GUI/MiniToolBarAlignment" value="bottom"/>
      <ExtraDataItem name="GUI/MiniToolBarAutoHide" value="on"/>
      <ExtraDataItem name="GUI/SaveMountedAtRuntime" value="yes"/>
      <ExtraDataItem name="GUI/Seamless" value="off"/>
      <ExtraDataItem name="GUI/ShowMiniToolBar" value="yes"/>
    </ExtraData>
    <Snapshot uuid="{f1e6edb3-6e12-4615-9642-a80a3a1ad115}" name="one" timeStamp="2010-02-07T20:01:20Z">
      <Hardware version="2">
        <CPU count="1">
          <HardwareVirtEx enabled="true" exclusive="false"/>
          <HardwareVirtExNestedPaging enabled="false"/>
          <HardwareVirtExVPID enabled="false"/>
          <PAE enabled="true"/>
        </CPU>
        <Memory RAMSize="360"/>
        <Boot>
          <Order position="1" device="Floppy"/>
          <Order position="2" device="DVD"/>
          <Order position="3" device="HardDisk"/>
          <Order position="4" device="None"/>
        </Boot>
        <Display VRAMSize="12" monitorCount="1" accelerate3D="false" accelerate2DVideo="false"/>
        <RemoteDisplay enabled="false" port="3389" authType="Null" authTimeout="5000"/>
        <BIOS>
          <ACPI enabled="true"/>
          <IOAPIC enabled="false"/>
          <Logo fadeIn="true" fadeOut="true" displayTime="0"/>
          <BootMenu mode="MessageAndMenu"/>
          <TimeOffset value="0"/>
          <PXEDebug enabled="false"/>
        </BIOS>
        <USBController enabled="false" enabledEhci="true"/>
        <Network>
          <Adapter slot="0" enabled="true" MACAddress="0800279C2E41" cable="true" speed="0" type="Am79C973">
            <NAT/>
          </Adapter>
          <Adapter slot="1" enabled="false" MACAddress="0800277D1707" cable="true" speed="0" type="Am79C973"/>
          <Adapter slot="2" enabled="false" MACAddress="080027FB5229" cable="true" speed="0" type="Am79C973"/>
          <Adapter slot="3" enabled="false" MACAddress="080027DE7343" cable="true" speed="0" type="Am79C973"/>
          <Adapter slot="4" enabled="false" MACAddress="0800277989CB" cable="true" speed="0" type="Am79C973"/>
          <Adapter slot="5" enabled="false" MACAddress="08002768E43B" cable="true" speed="0" type="Am79C973"/>
          <Adapter slot="6" enabled="false" MACAddress="080027903DF3" cable="true" speed="0" type="Am79C973"/>
          <Adapter slot="7" enabled="false" MACAddress="0800276A0A7D" cable="true" speed="0" type="Am79C973"/>
        </Network>
        <UART>
          <Port slot="0" enabled="false" IOBase="0x3f8" IRQ="4" hostMode="Disconnected"/>
          <Port slot="1" enabled="false" IOBase="0x3f8" IRQ="4" hostMode="Disconnected"/>
        </UART>
        <LPT>
          <Port slot="0" enabled="false" IOBase="0x378" IRQ="4"/>
          <Port slot="1" enabled="false" IOBase="0x378" IRQ="4"/>
        </LPT>
        <AudioAdapter controller="AC97" driver="CoreAudio" enabled="false"/>
        <SharedFolders/>
        <Clipboard mode="Bidirectional"/>
        <Guest memoryBalloonSize="0" statisticsUpdateInterval="0"/>
        <GuestProperties>
          <GuestProperty name="/VirtualBox/GuestInfo/OS/Product" value="Linux" timestamp="1265440664974640000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestInfo/OS/Release" value="2.6.24-26-virtual" timestamp="1265440664974987000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestInfo/OS/Version" value="#1 SMP Tue Dec 1 20:00:30 UTC 2009" timestamp="1265440664975592000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestInfo/OS/ServicePack" value="" timestamp="1265440664976342000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestAdd/Revision" value="3.1.2" timestamp="1265440664977228000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestAdd/Version" value="56127" timestamp="1265440664977917000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestInfo/OS/LoggedInUsers" value="1" timestamp="1265441395765168000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestInfo/Net/Count" value="1" timestamp="1265441395765770000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestInfo/Net/0/V4/IP" value="10.0.2.15" timestamp="1265441395765987000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestInfo/Net/0/V4/Broadcast" value="10.0.2.255" timestamp="1265441395766412000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestInfo/Net/0/V4/Netmask" value="255.255.255.0" timestamp="1265441395766827000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestInfo/Net/0/Status" value="Up" timestamp="1265441395767109000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestInfo/OS/NoLoggedInUsers" value="false" timestamp="1265440815142014000" flags=""/>
          <GuestProperty name="/VirtualBox/HostInfo/GUI/LanguageID" value="en_US" timestamp="1265440628402728000" flags=""/>
          <GuestProperty name="/VirtualBox/GuestInfo/OS/LoggedInUsersList" value="hobo" timestamp="1265441395763755000" flags=""/>
        </GuestProperties>
      </Hardware>
      <StorageControllers>
        <StorageController name="IDE Controller" type="PIIX4" PortCount="2">
          <AttachedDevice type="HardDisk" port="0" device="0">
            <Image uuid="{5f7ccd06-78ef-47e9-b2bc-515aedd2f288}"/>
          </AttachedDevice>
          <AttachedDevice type="DVD" port="1" device="0">
            <Image uuid="{4a08f52c-bca3-4908-8da4-4f48aaa4ebba}"/>
          </AttachedDevice>
        </StorageController>
      </StorageControllers>
    </Snapshot>
    <Hardware version="2">
      <CPU count="1">
        <HardwareVirtEx enabled="true" exclusive="false"/>
        <HardwareVirtExNestedPaging enabled="false"/>
        <HardwareVirtExVPID enabled="false"/>
        <PAE enabled="true"/>
      </CPU>
      <Memory RAMSize="360"/>
      <Boot>
        <Order position="1" device="Floppy"/>
        <Order position="2" device="DVD"/>
        <Order position="3" device="HardDisk"/>
        <Order position="4" device="None"/>
      </Boot>
      <Display VRAMSize="12" monitorCount="1" accelerate3D="false" accelerate2DVideo="false"/>
      <RemoteDisplay enabled="false" port="3389" authType="Null" authTimeout="5000"/>
      <BIOS>
        <ACPI enabled="true"/>
        <IOAPIC enabled="false"/>
        <Logo fadeIn="true" fadeOut="true" displayTime="0"/>
        <BootMenu mode="MessageAndMenu"/>
        <TimeOffset value="0"/>
        <PXEDebug enabled="false"/>
      </BIOS>
      <USBController enabled="false" enabledEhci="true"/>
      <Network>
        <Adapter slot="0" enabled="true" MACAddress="0800279C2E41" cable="true" speed="0" type="Am79C973">
          <NAT/>
        </Adapter>
        <Adapter slot="1" enabled="false" MACAddress="0800277D1707" cable="true" speed="0" type="Am79C973"/>
        <Adapter slot="2" enabled="false" MACAddress="080027FB5229" cable="true" speed="0" type="Am79C973"/>
        <Adapter slot="3" enabled="false" MACAddress="080027DE7343" cable="true" speed="0" type="Am79C973"/>
        <Adapter slot="4" enabled="false" MACAddress="0800277989CB" cable="true" speed="0" type="Am79C973"/>
        <Adapter slot="5" enabled="false" MACAddress="08002768E43B" cable="true" speed="0" type="Am79C973"/>
        <Adapter slot="6" enabled="false" MACAddress="080027903DF3" cable="true" speed="0" type="Am79C973"/>
        <Adapter slot="7" enabled="false" MACAddress="0800276A0A7D" cable="true" speed="0" type="Am79C973"/>
      </Network>
      <UART>
        <Port slot="0" enabled="false" IOBase="0x3f8" IRQ="4" hostMode="Disconnected"/>
        <Port slot="1" enabled="false" IOBase="0x3f8" IRQ="4" hostMode="Disconnected"/>
      </UART>
      <LPT>
        <Port slot="0" enabled="false" IOBase="0x378" IRQ="4"/>
        <Port slot="1" enabled="false" IOBase="0x378" IRQ="4"/>
      </LPT>
      <AudioAdapter controller="AC97" driver="CoreAudio" enabled="false"/>
      <SharedFolders/>
      <Clipboard mode="Bidirectional"/>
      <Guest memoryBalloonSize="0" statisticsUpdateInterval="0"/>
      <GuestProperties>
        <GuestProperty name="/VirtualBox/GuestInfo/OS/Product" value="Linux" timestamp="1265440664974640000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/OS/Release" value="2.6.24-26-virtual" timestamp="1265440664974987000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/OS/Version" value="#1 SMP Tue Dec 1 20:00:30 UTC 2009" timestamp="1265440664975592000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/OS/ServicePack" value="" timestamp="1265440664976342000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Revision" value="3.1.2" timestamp="1265440664977228000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestAdd/Version" value="56127" timestamp="1265440664977917000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/OS/LoggedInUsers" value="1" timestamp="1265441395765168000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/Net/Count" value="1" timestamp="1265441395765770000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/Net/0/V4/IP" value="10.0.2.15" timestamp="1265441395765987000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/Net/0/V4/Broadcast" value="10.0.2.255" timestamp="1265441395766412000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/Net/0/V4/Netmask" value="255.255.255.0" timestamp="1265441395766827000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/Net/0/Status" value="Up" timestamp="1265441395767109000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/OS/NoLoggedInUsers" value="false" timestamp="1265440815142014000" flags=""/>
        <GuestProperty name="/VirtualBox/HostInfo/GUI/LanguageID" value="en_US" timestamp="1265440628402728000" flags=""/>
        <GuestProperty name="/VirtualBox/GuestInfo/OS/LoggedInUsersList" value="hobo" timestamp="1265441395763755000" flags=""/>
      </GuestProperties>
    </Hardware>
    <StorageControllers>
      <StorageController name="IDE Controller" type="PIIX4" PortCount="2">
        <AttachedDevice type="HardDisk" port="0" device="0">
          <Image uuid="{2c16dd48-4cf1-497e-98fa-84ed55cfe71f}"/>
        </AttachedDevice>
        <AttachedDevice type="DVD" port="1" device="0">
          <Image uuid="{4a08f52c-bca3-4908-8da4-4f48aaa4ebba}"/>
        </AttachedDevice>
      </StorageController>
    </StorageControllers>
  </Machine>
</VirtualBox>
xml

    @name = "foo"

    # Just to be sure nothing is executed
    VirtualBox::Command.stubs(:execute).returns('')
  end

  def create_vm
    VirtualBox::Command.expects(:parse_xml).returns(Nokogiri::XML(@raw_xml))
    vm = VirtualBox::VM.load_from_xml(@name)
    assert vm
    vm
  end

  context "human readable info" do
    should "not pass --machinereadable into the showvminfo command" do
      VirtualBox::Command.expects(:vboxmanage).with("showvminfo", @name).once
      VirtualBox::VM.human_info(@name)
    end
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
    setup do
      @raw = <<-raw
"foo" {abcdefg}
"bar"  {zefaldf}
raw
    end

    should "list VMs then parse them" do
      global = mock("global")
      global.expects(:vms).once
      VirtualBox::Global.expects(:global).returns(global)
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
    setup do
      @nokogiri_xml = Nokogiri::XML(@raw_xml)
    end

    should "parse the XML then initializing the class" do
      VirtualBox::Command.expects(:parse_xml).with("foo").returns(@nokogiri_xml)
      VirtualBox::VM.expects(:new).with(@nokogiri_xml).once
      VirtualBox::VM.load_from_xml("foo")
    end

    should "initialize the attributes when called with an XML document" do
      VirtualBox::VM.any_instance.expects(:initialize_attributes).once.with(@nokogiri_xml)
      VirtualBox::VM.new(@nokogiri_xml)
    end
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
      VirtualBox::VM.expects(:all).returns([create_vm])
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