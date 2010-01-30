require File.join(File.dirname(__FILE__), '..', 'test_helper')

class NicTest < Test::Unit::TestCase
  setup do
    @data = {
      :nic1 => "bridged",
      :nic2 => "foo",
      :nic3 => "bar"
    }

    @caller = mock("caller")
    @caller.stubs(:name).returns("foo")

    VirtualBox::VM.stubs(:human_info).returns(<<-raw)
NIC 1:           MAC: 08002745B49F, Attachment: Bridged Interface 'en0: Ethernet', Cable connected: on, Trace: off (file: none), Type: Am79C973, Reported speed: 0 Mbps
NIC 2:           MAC: 08002745B49F, Attachment: Bridged Interface 'en0: Ethernet', Cable connected: on, Trace: off (file: none), Type: Am79C973, Reported speed: 0 Mbps
NIC 3:           MAC: 08002745B49F, Attachment: Bridged Interface 'en0: Ethernet', Cable connected: on, Trace: off (file: none), Type: Am79C973, Reported speed: 0 Mbps
raw
  end

  context "saving" do
    setup do
      @nic = VirtualBox::Nic.populate_relationship(@caller, @data)
      @vmname = "myvm"
    end

    should "use the vmname strung through the save" do
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm #{@vmname} --nic1 foo")

      nic = @nic[0]
      nic.nic = "foo"
      nic.save(@vmname)
    end

    should "use the proper index" do
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm #{@vmname} --nic2 far")

      nic = @nic[1]
      nic.nic = "far"
      nic.save(@vmname)
    end

    should "save the nictype" do
      VirtualBox::Command.expects(:vboxmanage).with("modifyvm #{@vmname} --nictype1 ZOO")

      nic = @nic[0]
      nic.nictype = "ZOO"
      assert nic.nictype_changed?
      nic.save(@vmname)
    end

    should "raise a CommandFailedException if it fails" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)

      nic = @nic[0]
      nic.nictype = "ZOO"
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        nic.save(@vmname)
      }
    end
  end

  context "populating relationships" do
    setup do
      @value = VirtualBox::Nic.populate_relationship(@caller, @data)
    end

    should "create the correct amount of objects" do
      assert_equal 3, @value.length
    end

    should "parse the type" do
      assert_equal "Am79C973", @value[0].nictype
    end
  end

  context "parsing nic data from human readable output" do
    setup do
      @raw = "NIC 1:           MAC: 08002745B49F, Attachment: Bridged Interface 'en0: Ethernet', Cable connected: on, Trace: off (file: none), Type: Am79C973, Reported speed: 0 Mbps"

      @multiline_raw = <<-raw
Storage Controller Port Count (0):      2
Storage Controller Name (1):            Floppy Controller
Storage Controller Type (1):            I82078
Storage Controller Instance Number (1): 0
Storage Controller Max Port Count (1):  1
Storage Controller Port Count (1):      1
IDE Controller (0, 0): /Users/mitchellh/Library/VirtualBox/HardDisks/HoboBase.vmdk (UUID: fb0256a9-5685-4bc2-98ff-5b7503586bf3)
IDE Controller (1, 0): Empty
Floppy Controller (0, 0): Empty
NIC 1:           MAC: 08002745B49F, Attachment: Bridged Interface 'en0: Ethernet', Cable connected: on, Trace: off (file: none), Type: Am79C973, Reported speed: 0 Mbps
NIC 2:           disabled
raw
    end

    should "only return valid objects in hash" do
      VirtualBox::VM.expects(:human_info).returns(@multiline_raw)
      result = VirtualBox::Nic.nic_data("foo")
      assert result.is_a?(Hash)
      assert_equal 1, result.length
    end

    should "return nil if its an invalid string" do
      assert_nil VirtualBox::Nic.parse_nic("FOO")
    end

    should "return proper data for valid string" do
      @name = :nic1
      @expected = {
        :mac => "08002745B49F",
        :attachment => "Bridged Interface 'en0: Ethernet'",
        :trace => "off (file: none)",
        :type => "Am79C973"
      }

      name, result = VirtualBox::Nic.parse_nic(@raw)
      assert_equal @name, name
      assert result.is_a?(Hash)

      @expected.each do |k,v|
        assert_equal v, result[k]
      end
    end

    should "ignore nics that are disabled" do
      assert_nil VirtualBox::Nic.parse_nic("NIC 1:    disabled")
    end
  end
end