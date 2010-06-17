require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class InterfaceAttributesTest < Test::Unit::TestCase
  class EmptyInterfaceAttributeModel
    include VirtualBox::AbstractModel::Attributable
    include VirtualBox::AbstractModel::InterfaceAttributes
  end

  class InterfaceAttributeModel < EmptyInterfaceAttributeModel
    attribute :foo
    attribute :foo2, :property_getter => :get_foo, :property_setter => :set_foo
    attribute :foo3, :property => :grab_foo3, :readonly => true
    attribute :foo4, :property => :put_foo4
    attribute :bar, :property => false
    attribute :ver, :version => "3.1.3"
  end

  context "converting spec to a proc" do
    setup do
      @instance = EmptyInterfaceAttributeModel.new
      @interface = mock("interface")
    end

    context "symbols" do
      should "convert to a proc which calls the symbol on the interface" do
        result = mock("result")
        proc = @instance.spec_to_proc(:foo)
        @interface.expects(:foo).once.returns(result)
        assert_equal result, proc.call(nil, @interface)
      end

      should "forward all parameters" do
        result = mock("result")
        proc = @instance.spec_to_proc(:foo)
        @interface.expects(:foo).with(1, 2, 3).once.returns(result)
        assert_equal result, proc.call(nil, @interface, :key, 1, 2, 3)
      end
    end

    context "procs" do
      should "leave proc as is" do
        result = mock("result")
        proc = Proc.new { |m| result }
        converted = @instance.spec_to_proc(proc)
        assert_equal proc, converted
        assert_equal result, converted.call(@interface)
      end
    end
  end

  context "loading a single interface attribute" do
    setup do
      @instance = InterfaceAttributeModel.new
      @interface = mock("interface")
      @interface.stubs(:foo).returns("foo")
    end

    should "return immediately if not a valid attribute" do
      @proc.expects(:call).never
      @instance.load_interface_attribute(:baz, @interface)
    end

    should "return immediately if is marked as a non-property" do
      @proc.expects(:call).never
      @instance.load_interface_attribute(:bar, @interface)
    end

    should "return immediately if version mismatch" do
      VirtualBox.stubs(:version).returns("3.2.4")
      @interface.expects(:ver).never
      @instance.load_interface_attribute(:ver, @interface)
    end

    should "load the attribute if version matches" do
      VirtualBox.stubs(:version).returns("3.1.3")
      @interface.expects(:ver).returns("foo")
      @instance.load_interface_attribute(:ver, @interface)
    end

    should "use the getter specified if exists" do
      key = :foo2
      @interface.expects(:get_foo).returns(:bar)
      @instance.expects(:write_attribute).with(key, :bar)
      @instance.load_interface_attribute(key, @interface)
    end

    should "use the property specified first" do
      key = :foo3
      @interface.expects(:grab_foo3).returns(:bar)
      @instance.expects(:write_attribute).with(key, :bar)
      @instance.load_interface_attribute(key, @interface)
    end

    should "use the attribute name if no getter is specified" do
      key = :foo
      @interface.expects(:foo).returns(:bar)
      @instance.expects(:write_attribute).with(key, :bar)
      @instance.load_interface_attribute(key, @interface)
    end

    should "write the attribute with the value of the proc" do
      key = :foo
      @instance.expects(:write_attribute).with(key, "foo").once
      @instance.load_interface_attribute(key, @interface)
    end
  end

  context "saving a single interface attribute" do
    setup do
      @instance = InterfaceAttributeModel.new
      @interface = mock("interface")

      @value = :bar
      @instance.stubs(:read_attribute).with(anything).returns(@value)
    end

    should "return immediately if not a valid attribute" do
      @proc.expects(:call).never
      @instance.save_interface_attribute(:baz, @interface)
    end

    should "return immediately if attribute doesn't have an interface setter" do
      @proc.expects(:call).never
      @instance.save_interface_attribute(:bar, @interface)
    end

    should "return immediately if version mismatch" do
      VirtualBox.stubs(:version).returns("3.2.4")
      @interface.expects(:ver).never
      @instance.save_interface_attribute(:ver, @interface)
    end

    should "load the attribute if version matches" do
      VirtualBox.stubs(:version).returns("3.1.3")
      @interface.expects(:ver=)
      @instance.save_interface_attribute(:ver, @interface)
    end

    should "save the attribute with the value of the proc" do
      key = :foo
      @interface.expects(:foo=).with(@value).once
      @instance.save_interface_attribute(key, @interface)
    end

    should "use the property specified first" do
      key = :foo4
      @interface.expects(:put_foo4).returns(:bar)
      @instance.save_interface_attribute(key, @interface)
    end

    should "use the setter if it exists" do
      key = :foo2
      @interface.expects(:set_foo).with(@value).once
      @instance.save_interface_attribute(key, @interface)
    end

    should "not save readonly attributes" do
      key = :foo3
      @interface.expects(:foo3=).never
      @instance.save_interface_attribute(key, @interface)
    end
  end

  context "loading all interface attributes" do
    setup do
      @instance = InterfaceAttributeModel.new
      @interface = mock('interface')
    end

    should "load each" do
      load_seq = sequence("load_seq")
      InterfaceAttributeModel.attributes.each do |key, options|
        @instance.expects(:load_interface_attribute).with(key, @interface)
      end

      @instance.load_interface_attributes(@interface)
    end
  end

  context "saving all interface attributes" do
    setup do
      @instance = InterfaceAttributeModel.new
      @interface = mock('interface')
    end

    should "save each" do
      InterfaceAttributeModel.attributes.each do |key, options|
        @instance.expects(:save_interface_attribute).with(key, @interface)
      end

      @instance.save_interface_attributes(@interface)
    end
  end
end
