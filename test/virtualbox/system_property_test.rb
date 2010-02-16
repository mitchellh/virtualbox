require File.join(File.dirname(__FILE__), '..', 'test_helper')

class SystemPropertyTest < Test::Unit::TestCase
  setup do
    @raw = <<-raw
VirtualBox Command Line Management Interface Version 3.1.2
(C) 2005-2009 Sun Microsystems, Inc.
All rights reserved.

Minimum guest RAM size:          4 Megabytes
Maximum guest RAM size:          3584 Megabytes
Minimum video RAM size:          1 Megabytes
Maximum video RAM size:          128 Megabytes
Minimum guest CPU count:         1
Maximum guest CPU count:         32
Maximum VDI size:                2097151 Megabytes
Maximum Network Adapter count:   8
Maximum Serial Port count:       2
Maximum Parallel Port count:     2
Maximum Boot Position:           4
Maximum IDE Controllers:         1
Maximum IDE Port count:          2
Maximum Devices per IDE Port:    2
Maximum SATA Controllers:        1
Maximum SATA Port count:         30
Maximum Devices per SATA Port:   1
Maximum SCSI Controllers:        1
Maximum SCSI Port count:         16
Maximum Devices per SCSI Port:   1
Maximum Floppy Controllers:      1
Maximum Floppy Port count:       1
Maximum Devices per Floppy Port: 2
Default machine folder:          /Users/mitchellh/Library/VirtualBox/Machines
Default hard disk folder:        /Users/mitchellh/Library/VirtualBox/HardDisks
VRDP authentication library:     VRDPAuth
Webservice auth. library:        VRDPAuth
Log history count:               3
raw
  end

  context "getting all system properties" do
    setup do
      VirtualBox::Command.stubs(:vboxmanage).returns(@raw)
    end

    should "return a new SystemProperty object" do
      result = VirtualBox::SystemProperty.all
      assert result.is_a?(VirtualBox::SystemProperty)
    end

    should "run the vboxmanage command and parse its output" do
      raw = mock("raw")
      VirtualBox::Command.expects(:vboxmanage).with("list", "systemproperties").returns(raw)
      VirtualBox::SystemProperty.expects(:parse_raw).with(raw).returns("foo")
      VirtualBox::SystemProperty.all
    end
  end

  context "parsing the raw output" do
    should "return a hash with the proper number of values" do
      result = VirtualBox::SystemProperty.parse_raw(@raw)
      assert result.is_a?(Hash)
      assert_equal 28, result.length
    end

    should "lowercase and convert each key to a symbol" do
      result = VirtualBox::SystemProperty.parse_raw(@raw)
      assert_equal "30", result[:maximum_sata_port_count]
    end
  end
end