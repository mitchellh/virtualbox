require File.expand_path("../../test_helper", __FILE__)

class HardDriveTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::HardDrive
    @interface = mock("interface")
  end

  context "device type" do
    should "be :hard_disk" do
      assert_equal :hard_disk, @klass.device_type
    end
  end

  context "retrieving all hard drives" do
    should "return an array of HardDrive objects" do
      media = mock("media")
      media.expects(:hard_drives).returns("foo")
      global = mock("global")
      global.expects(:media).returns(media)
      VirtualBox::Global.expects(:global).returns(global)
      assert_equal "foo", VirtualBox::HardDrive.all
    end
  end

  context "finding a hard drive" do
    setup do
      @all = []
      @klass.stubs(:all).returns(@all)
    end

    def mock_drive(uuid)
      drive = mock("hd-#{uuid}")
      drive.stubs(:uuid).returns(uuid)
      drive
    end

    should "return nil if it doesn't exist" do
      @all << mock_drive("foo")
      assert_nil @klass.find("bar")
    end

    should "return the matching drive if it is found" do
      drive = mock_drive("foo")
      @all << mock_drive("bar")
      @all << drive
      assert_equal drive, @klass.find("foo")
    end
  end

  context "with an instance" do
    setup do
      @klass.any_instance.stubs(:initialize_attributes)
      @instance = @klass.new(@interface)
    end

    context "physical size" do
      should "convert bytes to megabytes" do
        nonnormalized = 37548181
        normalized = @instance.bytes_to_megabytes(nonnormalized)
        @instance.expects(:read_attribute).with(:physical_size).returns(nonnormalized)
        assert_equal normalized, @instance.physical_size
      end
    end

    context "cloning" do
      setup do
        @system_properties = mock("system_properties")
        @virtualbox = mock("virtualbox")
        @lib = mock("lib")
        @new_medium = mock("new_medium")

        @hard_disk_format = "VDI"
        @hard_disk_folder = "foobar"

        VirtualBox::Lib.stubs(:lib).returns(@lib)
        @lib.stubs(:virtualbox).returns(@virtualbox)
        @virtualbox.stubs(:system_properties).returns(@system_properties)
        @system_properties.stubs(:default_hard_disk_format).returns(@hard_disk_format)
        @system_properties.stubs(:default_hard_disk_folder).returns(@hard_disk_folder)
      end

      should "clone the hard drive" do
        progress = mock("progress")
        @instance.expects(:create_hard_disk_medium).with("/foo.vdi", nil).returns(@new_medium)
        @interface.expects(:clone_to).with(@new_medium, :standard, nil).returns(progress)
        progress.expects(:wait_for_completion).with(-1)

        @instance.clone("/foo.vdi")
      end
    end
  end

  context "creating a hard drive" do
    setup do
      @klass.any_instance.stubs(:initialize_attributes)
      @instance = @klass.new
      @instance.stubs(:validate)

      @system_properties = mock("system_properties")
      @virtualbox = mock("virtualbox")
      @lib = mock("lib")
      @new_medium = mock("new_medium")

      @hard_disk_format = "VDI"
      @hard_disk_folder = "foobar"

      VirtualBox::Lib.stubs(:lib).returns(@lib)
      @lib.stubs(:virtualbox).returns(@virtualbox)
      @virtualbox.stubs(:system_properties).returns(@system_properties)
      @system_properties.stubs(:default_hard_disk_format).returns(@hard_disk_format)
      @system_properties.stubs(:default_hard_disk_folder).returns(@hard_disk_folder)
    end

    should "return false unless the record is new" do
      @instance.stubs(:new_record?).returns(false)
      assert_equal false, @instance.create
    end

    should "raise exception unless the record is valid" do
      @instance.stubs(:valid?).returns(false)
      assert_raises(VirtualBox::Exceptions::ValidationFailedException) do
        @instance.create
      end
    end

    should "create the hard drive" do
      logical_size = 1000
      progress = mock("progress")
      @instance.stubs(:location).returns(@hard_disk_folder)
      @instance.stubs(:format).returns(@hard_disk_format)
      @instance.stubs(:logical_size).returns(logical_size)
      @instance.expects(:create_hard_disk_medium).with(@hard_disk_folder, @hard_disk_format).returns(@new_medium)
      @new_medium.expects(:create_base_storage).with(logical_size, :standard).returns(progress)
      progress.expects(:wait_for_completion).with(-1)

      @instance.create
    end
  end

end
