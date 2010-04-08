require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class COMFFIUtilTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::COM::FFI::Util
  end

  context "converting function specs to FFI parameter lists" do
    def assert_spec(spec, expected)
      result = @klass.spec_to_ffi(spec)
      result.shift
      assert_equal expected, result
    end

    should "leaving primitives alone" do
      assert_spec([:int], [:int])
    end

    should "convert any out parameters to pointers" do
      assert_spec([[:out, :int]], [:pointer])
    end

    should "convert unicode strings to pointers" do
      assert_spec([:unicode_string], [:pointer])
    end

    should "convert COM interfaces to pointers" do
      assert_spec([:VirtualBox], [:pointer])
    end

    should "convert enums to ints" do
      assert_spec([:FirmwareType], [VirtualBox::COM::T_UINT32])
    end

    should "convert unknown classes to pointers" do
      assert_spec([:VirtualBoxFoo], [:pointer])
    end

    should "convert array parameters to two params" do
      assert_spec([[:unicode_string]], [VirtualBox::COM::T_UINT32, :pointer])
    end

    should "add a pointer at the beginning for the `this` parameter" do
      assert_equal [:pointer], @klass.spec_to_ffi([])
    end

    should "turn arrays into multiple pointers (one for size and one for the array)" do
      assert_spec([[:out, [:int]]], [:pointer, :pointer])
    end
  end

  context "camelizing" do
    should "camel case strings" do
      tests = {
        "foo_bar" => "FooBar",
        "foobar" => "Foobar",
        # Special cases below
        "guest_os_type" => "GuestOSType",
        "dhcp_servers" => "DHCPServers",
        "dvd_images" => "DVDImages",
        "usb_devices" => "USBDevices",
        "ram_size" => "RAMSize",
        "vram_size" => "VRAMSize",
        "accelerate_3d_enabled" => "Accelerate3DEnabled",
        "bios_settings" => "BIOSSettings",
        "vrdp_server" => "VRDPServer",
        "get_hw_virt_ex_property" => "GetHWVirtExProperty",
        "query_saved_screenshot_png_size" => "QuerySavedScreenshotPNGSize",
        "acpi_enabled" => "ACPIEnabled",
        "io_apic_enabled" => "IOAPICEnabled",
        "pxe_debug_enabled" => "PXEDebugEnabled",
        "nat_foo" => "NATFoo",
        "ide_emulation" => "IDEEmulation",
        "create_vfs_explorer" => "CreateVFSExplorer",
        "ip_address" => "IPAddress",
        "max_vdi_size" => "MaxVDISize",
        "cpu_count" => "CPUCount",
        "recommended_hdd" => "RecommendedHDD"
      }

      tests.each do |arg, expected|
        assert_equal expected, @klass.camelize(arg)
      end
    end
  end
end