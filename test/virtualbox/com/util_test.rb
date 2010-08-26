require File.expand_path("../../../test_helper", __FILE__)

class COMUtilTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::COM::Util
  end

  context "checking for interfaces" do
    should "return true for existing interfaces" do
      assert @klass.interface?(:VirtualBox)
    end

    should "return false for non-existing interfaces" do
      assert !@klass.interface?(:IDontExist)
    end
  end
end
