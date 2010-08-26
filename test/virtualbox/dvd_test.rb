require File.expand_path("../../test_helper", __FILE__)

class DVDTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::DVD
  end

  context "device type" do
    should "be :dvd" do
      assert_equal :dvd, @klass.device_type
    end
  end

  context "retrieving all dvds" do
    setup do
      @media = mock("media")
      @media.expects(:dvds).returns([])
      @global = mock("global")
      @global.expects(:media).returns(@media)
    end

    should "return an array of DVD objects" do
      VirtualBox::Global.expects(:global).returns(@global)
      result = VirtualBox::DVD.all
      assert result.is_a?(Array)
    end
  end
end
