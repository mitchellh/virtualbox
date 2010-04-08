require File.join(File.dirname(__FILE__), '..', 'test_helper')

class VersionTest < Test::Unit::TestCase
  module VersionTestMod
    extend VirtualBox::Version
  end

  setup do
    @lib = mock("lib")
    @vbox = mock("vbox")

    VirtualBox::Lib.stubs(:lib).returns(@lib)
    @lib.stubs(:virtualbox).returns(@vbox)

    @module = VersionTestMod
  end

  should "return the version" do
    version = mock("version")
    @vbox.expects(:version).returns(version)
    assert_equal version, @module.version
  end

  should "return the revision" do
    revision = mock("revision")
    @vbox.expects(:revision).returns(revision)
    assert_equal revision, @module.revision
  end
end