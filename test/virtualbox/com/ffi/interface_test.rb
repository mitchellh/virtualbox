require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class COMFFIInterfaceTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::COM::FFI::Interface
    @interface = mock("interface")
    @parent = mock("parent")
  end

  context "specifying a com interface" do
    setup do
      @com_interface = mock("com_interface")
      VirtualBox::COM::Util.stubs(:versioned_interface).returns(@com_interface)
      @klass.stubs(:define_vtbl_parent_for_interface)
      @klass.stubs(:define_vtbl_for_interface)
    end

    should "get the interface with respect to the COM interfaces" do
      VirtualBox::COM::Util.expects(:versioned_interface).with(@interface).returns(@com_interface)
      @klass.com_interface(@interface, @parent)
    end

    should "define the vtbl parent and vtbl" do
      @klass.expects(:define_vtbl_parent_for_interface).with(@com_interface)
      @klass.expects(:define_vtbl_for_interface).with(@com_interface, @parent)
      @klass.com_interface(@interface, @parent)
    end
  end

  context "defining the vtbl parent class" do
    setup do
      @klass.layout_args.clear
    end

    should "create a basic struct with a pointer" do
      @klass.expects(:const_set).with() do |name, klass|
        assert_equal "VtblParent", name
        assert_equal FFI::Struct, klass.superclass

        true
      end

      @klass.define_vtbl_parent_for_interface(@interface)
    end
  end

  context "defining the vtbl class" do
    setup do
      @klass.layout_args.clear

      @klass.stubs(:define_interface_parent)
      @klass.stubs(:define_interface_functions)
      @klass.stubs(:define_interface_properties)
    end

    should "define the properties then functions" do
      layout_mock = mock("layout")
      layout_mock.stubs(:layout)
      @klass.stubs(:const_set).returns(layout_mock)

      def_seq = sequence("define_seq")
      @klass.expects(:define_interface_parent).once.in_sequence(def_seq)
      @klass.expects(:define_interface_properties).once.in_sequence(def_seq)
      @klass.expects(:define_interface_functions).once.in_sequence(def_seq)
      @klass.define_vtbl_for_interface(@interface)
    end

    should "define the constant with the proper class" do
      layout_args = [[:foo], :bar]
      layout_args.stubs(:clear) # Don't let the method overwrite them

      klass = mock("klass")
      klass.expects(:layout).with(*layout_args.flatten).once
      Class.expects(:new).with(::FFI::Struct).returns(klass)
      @klass.stubs(:layout_args).returns(layout_args)

      @klass.expects(:const_set).with() do |name, set_klass|
        assert_equal "Vtbl", name
        assert_equal klass, set_klass

        true
      end.returns(klass)

      @klass.define_vtbl_for_interface(@interface)
    end
  end

  context "defining the interface parent" do
    should "do nothing if nil is given" do
      @klass.layout_args.expects(:<<).never
      assert_nothing_raised { @klass.define_interface_parent(nil) }
    end

    should "get the class in the context of the FFI namespace" do
      name = :foo
      klass = mock("klass")
      Object.expects(:module_eval).with("::VirtualBox::COM::FFI::#{VirtualBox::COM::Util.version_const}::#{name}::Vtbl").returns(klass)
      @klass.layout_args.expects(:<<).with([:superklass, klass])
      @klass.define_interface_parent(name)
    end
  end

  context "defining all interface functions" do
    setup do
      @functions = []
      @interface.stubs(:functions).returns(@functions)
    end

    def add_function(name, type, spec, opts={})
      @functions << [name, {
        :value_type => type,
        :spec => spec,
        :opts => opts
      }]
    end

    should "define a function for the function" do
      name = :foo
      type = :bar
      spec = [:baz]
      add_function(name, type, spec)

      @klass.expects(:define_interface_function).with(name, type, spec).once
      @klass.define_interface_functions(@interface)
    end

    should "define functions in order" do
      add_function(:foo, :bar, [:baz])
      add_function(:bar, :baz, [:foo])

      def_seq = sequence('define_seq')
      @functions.each do |name, opts|
        type = opts[:value_type]
        spec = opts[:spec]
        @klass.expects(:define_interface_function).with(name, type, spec).in_sequence(def_seq)
      end

      @klass.define_interface_functions(@interface)
    end
  end

  context "defining a single interface function" do
    setup do
      @properties = []
      @interface.stubs(:properties).returns(@properties)
    end

    def add_property(name, type, opts={})
      @properties << [name, {
        :value_type => type,
        :opts => opts
      }]
    end

    should "define a getter and setter for properties" do
      name = :foo
      type = :int
      add_property(name, type)

      @klass.expects(:define_interface_function).with("get_#{name}".to_sym, type)
      @klass.expects(:define_interface_function).with("set_#{name}".to_sym, nil, [type])
      @klass.define_interface_properties(@interface)
    end

    should "not define a setter for readonly properties" do
      name = :foo
      type = :int
      add_property(name, type, :readonly => true)

      @klass.expects(:define_interface_function).with("get_#{name}".to_sym, type)
      @klass.expects(:define_interface_function).with("set_#{name}".to_sym, nil, [type]).never
      @klass.define_interface_properties(@interface)
    end

    should "add properties in order" do
      add_property(:foo, :int)
      add_property(:bar, :uint)

      def_seq = sequence('define_seq')
      @properties.each do |name, opts|
        type = opts[:value_type]
        @klass.expects(:define_interface_function).with("get_#{name}".to_sym, type).in_sequence(def_seq)
        @klass.expects(:define_interface_function).with("set_#{name}".to_sym, nil, [type]).in_sequence(def_seq)
      end

      @klass.define_interface_properties(@interface)
    end
  end

  context "defining a function" do
    setup do
      @klass.layout_args.clear

      @name = :foo
      @spec = [:unicode_string]
      @ffi_spec = VirtualBox::COM::FFI::Util.spec_to_ffi(@spec)
    end

    should "append the return type to the spec" do
      expected = VirtualBox::COM::FFI::Util.spec_to_ffi(@spec.dup.push([:out, :int]))

      @klass.expects(:callback).with(@name, expected, VirtualBox::COM::FFI::NSRESULT_TYPE)
      @klass.define_interface_function(@name, :int, @spec)
    end

    should "turn the spec into FFI parameters, and create the callback" do
      @klass.expects(:callback).with(@name, @ffi_spec, VirtualBox::COM::FFI::NSRESULT_TYPE)
      @klass.define_interface_function(@name, nil, @spec)
    end

    should "add to the layout args" do
      @klass.layout_args.expects(:<<).with([@name, @name]).once
      @klass.define_interface_function(@name, nil, @spec)
    end
  end

  context "initializing" do
    setup do
      @pointer = mock("pointer")
    end

    should "initialize the vtbl structs" do
      @klass.any_instance.expects(:initialize_vtbl).with(@pointer)
      @klass.new(@pointer)
    end
  end

  context "initializing vtbl" do
    setup do
      @pointer = mock("pointer")
      @klass = VirtualBox::COM::FFI::Util.versioned_interface(:VirtualBox)
    end

    should "initialize the VtblParent then the Vtbl" do
      vtbl_pointer = mock("vtbl_pointer")
      vtbl_parent = mock("vtbl_parent")
      vtbl_parent.stubs(:[]).with(:vtbl).returns(vtbl_pointer)
      vtbl = mock("vtbl")

      init_seq = sequence("init_seq")
      @klass::VtblParent.expects(:new).with(@pointer).returns(vtbl_parent).in_sequence(init_seq)
      @klass::Vtbl.expects(:new).with(vtbl_pointer).returns(vtbl).in_sequence(init_seq)

      instance = @klass.new(@pointer)
      assert_equal vtbl_parent, instance.vtbl_parent
      assert_equal vtbl, instance.vtbl
    end
  end
end