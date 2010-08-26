require File.expand_path("../../../test_helper", __FILE__)

class COMFFIInterfaceBaseTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::COM::FFIInterface
  end

  context "class methods" do
    context "setting up" do
      should "set the ffi lib to the given path then attach function" do
        lib = :foo

        setup_seq = sequence('setup_seq')
        @klass.expects(:ffi_lib).with(lib).in_sequence(setup_seq)
        @klass.expects(:attach_function).with(:VBoxGetXPCOMCFunctions, anything, anything).in_sequence(setup_seq)
        @klass.setup(lib)
      end
    end

    context "creating" do
      should "setup the initialize" do
        lib = :foo
        result = mock("result")
        create_seq = sequence("create_seq")
        @klass.expects(:setup).with(lib).in_sequence(create_seq)
        @klass.expects(:new).returns(result).in_sequence(create_seq)
        assert_equal result, @klass.create(lib)
      end
    end
  end

  context "initialization" do
    should "initialize com interface" do
      @klass.any_instance.expects(:initialize_com).once
      @klass.new
    end
  end

  context "initializing com interface" do
    # TODO
  end
end
