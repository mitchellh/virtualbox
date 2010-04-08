require File.join(File.dirname(__FILE__), '..', 'test_helper')

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

    context "cloning" do
      setup do
        @system_properties = mock("system_properties")
        @virtualbox = mock("virtualbox")
        @lib = mock("lib")

        @hard_disk_folder = "foobar"

        VirtualBox::Lib.stubs(:lib).returns(@lib)
        @lib.stubs(:virtualbox).returns(@virtualbox)
        @virtualbox.stubs(:system_properties).returns(@system_properties)
        @system_properties.stubs(:default_hard_disk_folder).returns(@hard_disk_folder)
      end

      should "clone the hard drive" do
        format = "VDI"
        new_medium = mock("new_medium")
        progress = mock("progress")
        @virtualbox.expects(:create_hard_disk).with(format, "/foo.vdi").returns(new_medium)
        @interface.expects(:clone_to).with(new_medium, :standard, nil).returns(progress)
        progress.expects(:wait_for_completion).with(-1)

        @instance.clone("/foo.vdi")
      end
    end
  end
end