require File.join(File.dirname(__FILE__), '..', 'test_helper')

class GlobalTest < Test::Unit::TestCase
  context "parsing configuration XML" do
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