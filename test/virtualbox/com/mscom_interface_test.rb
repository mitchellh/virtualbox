require File.expand_path("../../../test_helper", __FILE__)

class COMMSCOMInterfaceBaseTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::COM::MSCOMInterface
  end
  context "initialization" do
    should "initialize MSCOM interface" do
      @klass.any_instance.expects(:initialize_mscom).once
      @klass.new
    end
  end

  context "initializing mscom interface" do
    # TODO
  end
end
