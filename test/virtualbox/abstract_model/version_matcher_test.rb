require File.expand_path("../../../test_helper", __FILE__)

class VersionMatcherTest < Test::Unit::TestCase
  setup do
    @module = VirtualBox::AbstractModel::VersionMatcher
    @klass = Class.new
    @klass.send(:extend, @module)
  end

  context "asserting version matches" do
    should "raise an exception if versions do not match" do
      assert_raises(VirtualBox::Exceptions::UnsupportedVersionException) {
        @klass.assert_version_match("3.1", "3.2.4")
      }
    end

    should "not raise an exception if versions do match" do
      assert_nothing_raised {
        @klass.assert_version_match("3.0", "3.0.14")
      }
    end
  end

  context "version matching" do
    should "return true if versions match" do
      assert @klass.version_match?("3.2", "3.2.4")
      assert !@klass.version_match?("3.1", "3.2.4")
    end
  end

  context "splitting version" do
    should "split into a max of two parts by period" do
      assert_equal %W[3 2], @klass.split_version("3.2.0")
      assert_equal %W[3 1], @klass.split_version("3.1.1.1.1")
    end

    should "return an empty array if it can't split" do
      assert_equal [], @klass.split_version(nil)
    end
  end
end
