require File.join(File.dirname(__FILE__), '..', 'test_helper')

class GlobalTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::Global
  end

  context "getting the global object" do
    setup do
      @lib = mock('lib')
      VirtualBox::Lib.stubs(:lib).returns(@lib)
      @klass.reset!
    end

    should "initialize the object with the lib once" do
      instance =  mock("instance")
      @klass.expects(:new).with(@lib).once.returns(instance)
      assert_equal instance, @klass.global
      assert_equal instance, @klass.global
      assert_equal instance, @klass.global
    end

    should "initialize the object if reload is set" do
      instance = mock("instance")
      @klass.expects(:new).with(@lib).twice.returns(instance)
      assert_equal instance, @klass.global
      assert_equal instance, @klass.global(true)
      assert_equal instance, @klass.global
    end
  end

  context "with an instance" do
    setup do
      @lib = mock("lib")
      @instance = @klass.new(@lib)
    end

    should "be an existing record, always" do
      assert !@instance.new_record?
    end

    should "setup the lib attribute on initialization" do
      assert_equal @lib, @instance.lib
    end
  end
end