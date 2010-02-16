require File.join(File.dirname(__FILE__), '..', 'test_helper')

class GlobalTest < Test::Unit::TestCase
  context "getting the global config" do
    should "only get it once, then cache" do
      VirtualBox::Global.expects(:config).returns(mock_xml_doc).once
      result = VirtualBox::Global.global(true)
      assert result
      assert result.equal?(VirtualBox::Global.global)
    end

    should "reload if reload is true" do
      VirtualBox::Global.expects(:config).returns(mock_xml_doc).twice
      result = VirtualBox::Global.global(true)
      assert result
      assert !result.equal?(VirtualBox::Global.global(true))
    end

    should "reload if global reload flag is set" do
      VirtualBox::Global.reload!
      VirtualBox::Global.expects(:config).returns(mock_xml_doc).once
      VirtualBox::Global.global
      assert !VirtualBox::Global.reload?
    end
  end

  context "parsing configuration XML" do
    setup do
      File.stubs(:exist?).returns(true)
      VirtualBox::Command.stubs(:parse_xml)
    end

    should "check the file with the expanded path" do
      File.stubs(:expand_path).returns("FOO")
      File.expects(:exist?).with("FOO").returns(true)
      VirtualBox::Global.config
    end

    should "raise an error if the config XML doesn't exist" do
      File.expects(:exist?).returns(false)
      assert_raises(VirtualBox::Exceptions::ConfigurationException) do
        VirtualBox::Global.config
      end
    end

    should "use Command.parse_xml to parse" do
      VirtualBox::Command.expects(:parse_xml).with(anything).once
      VirtualBox::Global.config
    end

    should "use the set vboxconfig to parse xml" do
      VirtualBox::Global.vboxconfig = "/foo"
      VirtualBox::Command.expects(:parse_xml).with("/foo").once
      VirtualBox::Global.config
    end

    should "file expand path the vboxconfig path" do
      VirtualBox::Global.vboxconfig = "foo"
      VirtualBox::Command.expects(:parse_xml).with(File.expand_path("foo")).once
      VirtualBox::Global.config
    end
  end

  context "expanding path" do
    setup do
      VirtualBox::Global.vboxconfig = "/foo/bar/baz.rb"
    end

    should "expand the path properly" do
      assert_equal "/foo/bar/vroom/rawr.bak", VirtualBox::Global.expand_path("vroom/rawr.bak")
    end

    should "expand the path relative to the vboxconfig directory" do
      File.expects(:expand_path).with("foo", "/foo/bar").once
      VirtualBox::Global.expand_path("foo")
    end
  end
end