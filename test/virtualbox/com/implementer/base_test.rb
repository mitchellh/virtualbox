require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class COMImplementerBaseTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::COM::Implementer::Base
    @interface = mock("interface")
    @lib = mock("lib")
  end

  context "with an instance" do
    setup do
      @instance = @klass.new(@interface, @lib)
    end

    context "inferring types" do
      should "return the proper values" do
        expectations = {
          :int => [:int, :int],
          :unicode_string => [:pointer, :unicode_string],
          :Host => [:pointer, :interface]
        }

        expectations.each do |original, result|
          assert_equal result, @instance.infer_type(original)
        end
      end
    end

    context "getting an interface class" do
      should "get from COM::Interface and return" do
        result = mock("result")
        type_name = :foo
        VirtualBox::COM::FFI::Util.expects(:interface_klass).with(type_name).returns(result)
        assert_equal result, @instance.interface_klass(type_name)
      end
    end
  end
end
