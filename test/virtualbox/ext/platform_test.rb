require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')
require 'virtualbox/ext/platform'

class PlatformTest < Test::Unit::TestCase
  context "mac" do
    should "return true if it contains darwin" do
      success = ["i386-darwin", "i686-darwin10", "imadarwin"]
      success.each do |item|
        VirtualBox::Platform.stubs(:platform).returns(item)
        assert VirtualBox::Platform.mac?
      end
    end
  end

  context "windows" do
    should "return true if it contains mswin" do
      success = ["i386-mswin32", "i686-mswin64", "imswin"]
      success.each do |item|
        VirtualBox::Platform.stubs(:platform).returns(item)
        assert VirtualBox::Platform.windows?
      end
    end

    should "return true if it contains mingw" do
      success = ["i386-mingw32", "i686-mingw64", "mingw"]
      success.each do |item|
        VirtualBox::Platform.stubs(:platform).returns(item)
        assert VirtualBox::Platform.windows?
      end
    end

    should "return true if it contains cygwin" do
      success = ["i386-cygwin", "i686-cygwin64", "cygwin"]
      success.each do |item|
        VirtualBox::Platform.stubs(:platform).returns(item)
        assert VirtualBox::Platform.windows?
      end
    end
  end

  context "linux" do
    should "return true if it contains linux" do
      success = ["i386-linux", "i686-linux241", "linux"]
      success.each do |item|
        VirtualBox::Platform.stubs(:platform).returns(item)
        assert VirtualBox::Platform.linux?
      end
    end
  end
end