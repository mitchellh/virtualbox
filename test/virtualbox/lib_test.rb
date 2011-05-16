require File.expand_path("../../test_helper", __FILE__)

class LibTest < Test::Unit::TestCase
  context "the virtualbox library file path" do
    setup do
      VirtualBox::Lib.lib_path = nil
    end

    should "return the path if its set" do
      File.expects(:expand_path).with("foo").returns("expanded_foo")
      VirtualBox::Lib.lib_path = "foo"
      assert_equal "expanded_foo", VirtualBox::Lib.lib_path
    end

    should "return Mac-path if on mac" do
      result = ["/Applications/VirtualBox.app/Contents/MacOS/VBoxXPCOMC.dylib"]
      VirtualBox::Platform.stubs(:mac?).returns(true)

      assert_equal result, VirtualBox::Lib.lib_path
    end

    should "return Windows-path if on windows" do
      result = "Unknown"
      VirtualBox::Platform.stubs(:mac?).returns(false)
      VirtualBox::Platform.stubs(:linux?).returns(false)
      VirtualBox::Platform.stubs(:windows?).returns(true)

      assert_equal result, VirtualBox::Lib.lib_path
    end

    should "return Linux-path if on linux" do
      result = ["/opt/VirtualBox/VBoxXPCOMC.so", "/usr/lib/virtualbox/VBoxXPCOMC.so", "/usr/lib64/virtualbox/VBoxXPCOMC.so"]
      VirtualBox::Platform.stubs(:mac?).returns(false)
      VirtualBox::Platform.stubs(:windows?).returns(false)
      VirtualBox::Platform.stubs(:linux?).returns(true)

      assert_equal result, VirtualBox::Lib.lib_path
    end

    should "return 'unknown' otherwise" do
      result = "Unknown"
      VirtualBox::Platform.stubs(:mac?).returns(false)
      VirtualBox::Platform.stubs(:windows?).returns(false)
      VirtualBox::Platform.stubs(:linux?).returns(false)

      assert_equal result, VirtualBox::Lib.lib_path
    end
  end

  context "accessing the lib" do
    setup do
      @lib_path = "foo"
      VirtualBox::Lib.stubs(:lib_path).returns(@lib_path)
      VirtualBox::Lib.reset!
    end

    should "create a new Lib instance with the lib path once" do
      instance = mock("instance")
      VirtualBox::Lib.expects(:new).once.returns(instance)
      assert_equal instance, VirtualBox::Lib.lib
      assert_equal instance, VirtualBox::Lib.lib
      assert_equal instance, VirtualBox::Lib.lib
    end
  end

  context "init-ing" do
    setup do
      @lib_path = "foo"

      @virtualbox = mock("virtualbox")
      @session = mock("session")
      @interface = mock("interface")
      @interface.stubs(:virtualbox).returns(@virtualbox)
      @interface.stubs(:session).returns(@session)
    end

    should "call init on FFI with the lib path for mac" do
      VirtualBox::Platform.stubs(:windows?).returns(false)
      VirtualBox::COM::FFIInterface.expects(:create).with(@lib_path).once.returns(@interface)
      lib = VirtualBox::Lib.new(@lib_path)
      assert_equal @virtualbox, lib.virtualbox
      assert_equal @session, lib.session
    end

    should "init MSCOM for windows" do
      VirtualBox::Platform.stubs(:windows?).returns(true)
      VirtualBox::COM::MSCOMInterface.expects(:new).once.returns(@interface)
      lib = VirtualBox::Lib.new(@lib_path)
      assert_equal @virtualbox, lib.virtualbox
      assert_equal @session, lib.session
    end
  end
end
