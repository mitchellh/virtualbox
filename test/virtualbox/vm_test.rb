require File.join(File.dirname(__FILE__), '..', 'test_helper')

class VMTest < Test::Unit::TestCase
  context "finding a VM by name" do
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

      @expected = {
        :name   => "foo",
        :ostype => "Ubuntu",
        :uuid   => "8710d3db-d96a-46ed-9004-59fa891fda90"
      }

      @name = "foo"
    end
    
    should "return a VM object with proper attributes" do
      VirtualBox::Command.expects(:vboxmanage).with("showvminfo #{@name} --machinereadable").returns(@raw).once
      vm = VirtualBox::VM.find(@name)
      
      assert vm
      
      @expected.each do |k,v|
        assert_equal v, vm.read_attribute(k)
      end
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