require File.expand_path("../../../../test_helper", __FILE__)

class COMImplementerFFITest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::COM::Implementer::FFI
    @interface = mock("interface")
  end

  context "with an instance" do
    setup do
      @lib_base = mock("lib_base")
      @ffi_interface = mock("ffi_interface")
      @ffi_class = mock("ffi_class")
      @pointer = mock("pointer")

      @ffi_class.stubs(:new).returns(@ffi_interface)
      @klass.any_instance.stubs(:ffi_class).returns(@ffi_class)

      @instance = @klass.new(@interface, @lib_base, @pointer)
    end

    context "reading a property" do
      should "call call_vtbl_function with the proper arguments" do
        @instance.expects(:call_vtbl_function).with(:get_foo, [[:out, :bar]])
        @instance.read_property(:foo, { :value_type => :bar })
      end
    end

    context "writing a property" do
      should "call call_vtbl_function with the proper arguments" do
        @instance.expects(:call_vtbl_function).with(:set_foo, [:bar], [7])
        @instance.write_property(:foo, 7, { :value_type => :bar })
      end
    end

    context "calling a function" do
      should "call call_vtbl_function with the proper arguments" do
        @instance.expects(:call_vtbl_function).with(:say_hello, [:int, [:out, :string]], [1, 2, 3])
        @instance.call_function(:say_hello, [1, 2, 3], {
          :value_type => :string,
          :spec => [:int]
        })
      end
    end

    context "calling a vtbl function" do
      setup do
        @vtbl = mock("vtbl")
        @vtbl_parent = mock("vtbl_parent")
        @ffi_interface.stubs(:vtbl).returns(@vtbl)
        @ffi_interface.stubs(:vtbl_parent).returns(@vtbl_parent)

        @proc = mock("proc")

        @name = :foo
        @spec = [:bar]
        @args = [:baz]
      end

      should "pass in the formal args then return the values from them" do
        result = mock("result")
        @formal = [:foo]

        @instance.expects(:spec_to_args).with(@spec, @args).returns(@formal)
        @instance.expects(:call_and_check).with(@name, @vtbl_parent, *@formal)
        @instance.expects(:values_from_formal_args).with(@spec, @formal).returns(result)
        assert_equal result, @instance.call_vtbl_function(@name, @spec, @args)
      end
    end

    context "function calling and error checking" do
      setup do
        @function = mock("function")
        @function.stubs(:call).returns(0)

        @name = :foo
        @vtbl = { @name => @function}
        @ffi_interface.stubs(:vtbl).returns(@vtbl)
      end

      should "raise an exception if an error occurred" do
        @function.expects(:call).returns(0x8000_4002)
        assert_raises(VirtualBox::Exceptions::COMException) {
          @instance.call_and_check(@name)
        }
      end

      should "not raise an exception if an error did not occur" do
        @function.expects(:call).returns(0x0000_0000)
        assert_nothing_raised {
          @instance.call_and_check(@name)
        }
      end

      should "not raise an exception for NS_ERROR_NOT_IMPLEMENTED" do
        @function.expects(:call).returns(0x8000_4001)
        assert_nothing_raised {
          @instance.call_and_check(@name)
        }
      end

      should "forward arguments" do
        @function.expects(:call).with(1,2,3).returns(0)
        assert_nothing_raised {
          @instance.call_and_check(@name, 1, 2, 3)
        }
      end
    end

    context "result code mapping" do
      should "return a mapped exception object if it exists" do
        assert_equal VirtualBox::Exceptions::ObjectNotFoundException, @instance.exception_map(0x80BB_0001)
      end

      should "return COMException if no mapping is found" do
        assert_equal VirtualBox::Exceptions::COMException, @instance.exception_map(-5)
      end
    end

    context "spec to formal argument list" do
      setup do
        @pointer = mock("pointer")
        @instance.stubs(:pointer_for_type).returns(@pointer)
      end

      should "replace primitives with their types" do
        assert_equal [7], @instance.spec_to_args([:int], [7])
      end

      should "replace booleans with 1/0" do
        bool = VirtualBox::COM::T_BOOL
        assert_equal [1,0], @instance.spec_to_args([bool, bool], [true, false])
      end

      should "replace single out items with a pointer" do
        @instance.expects(:pointer_for_type).with(:foo).returns(@pointer)
        assert_equal [@pointer], @instance.spec_to_args([[:out, :foo]])
      end

      should "convert Ruby strings into unicode strings" do
        spec = [VirtualBox::COM::WSTRING]
        args = ["foo"]

        @instance.expects(:string_to_utf16).with(args[0]).returns("bar")
        assert_equal ["bar"], @instance.spec_to_args(spec, args)
      end

      should "convert interfaces with nil arguments to nil" do
        spec = [:Machine]
        args = [nil]

        assert_equal [nil], @instance.spec_to_args(spec, args)
      end

      should "convert enums to their property indices" do
        spec = [:FirmwareType]
        args = [:efi]

        assert_equal [1], @instance.spec_to_args(spec, args)
      end

      should "replace in array types with two parameters" do
        @array = [true, false, false]
        result = @instance.spec_to_args([[VirtualBox::COM::T_BOOL]], [@array])
        assert_equal 2, result.length
        assert_equal @array.length, result[0]
        assert result[1].kind_of?(::FFI::MemoryPointer)
      end

      should "replace out array types with two parameters" do
        @counter_pointer = mock("count_pointer")
        @pointer = mock("pointer")

        @instance.expects(:pointer_for_type).with(VirtualBox::COM::T_UINT32).returns(@count_pointer)
        @instance.expects(:pointer_for_type).with(:foo).returns(@pointer)
        assert_equal [@count_pointer, @pointer], @instance.spec_to_args([[:out, [:foo]]])
      end
    end

    context "values from a formal parameter list" do
      should "return nil if there are no output parameters" do
        spec = []
        formal = []

        assert_nil @instance.values_from_formal_args(spec, formal)
      end

      should "dereference the pointer with proper type" do
        pointer = mock("pointer")
        spec = [[:out, :foo]]
        formal = [pointer]

        result = mock("result")
        @instance.expects(:dereference_pointer).with(pointer, :foo).once.returns(result)
        assert_equal result, @instance.values_from_formal_args(spec, formal)
      end

      should "dereference the array pointer with the proper type" do
        count_pointer = mock("count_pointer")
        pointer = mock("pointer")
        count = mock("count")
        result = mock("result")
        spec = [[:out, [:foo]]]
        formal = [count_pointer, pointer]

        @instance.expects(:dereference_pointer).with(count_pointer, VirtualBox::COM::T_UINT32).returns(count)
        @instance.expects(:dereference_pointer_array).with(pointer, :foo, count).returns(result)
        assert_equal result, @instance.values_from_formal_args(spec, formal)
      end

      should "return an array for multiple values" do
        spec = [:int, [:out, :foo], [:out, :bar]]
        formal = [1,2,3]

        result = mock("result")
        @instance.stubs(:dereference_pointer).returns(result)
        assert_equal [result, result], @instance.values_from_formal_args(spec, formal)
      end
    end

    context "pointers for type" do
      setup do
        @pointer = mock("pointer")
        FFI::MemoryPointer.stubs(:new).returns(@pointer)
      end

      should "create a pointer type for the given type" do
        @instance.expects(:infer_type).with(:MyType).returns([:pointer, :struct])
        FFI::MemoryPointer.expects(:new).with(:pointer).once.returns(@pointer)
        @instance.pointer_for_type(:MyType) do |ptr, type|
          assert_equal :struct, type
        end
      end

      should "return the result of the yield" do
        expected = mock("result")
        result = @instance.pointer_for_type(:int) do |ptr, type|
          expected
        end

        assert_equal expected, result
      end

      should "return the pointer if no block is given" do
        assert_equal @pointer, @instance.pointer_for_type(:int)
      end
    end

    context "dereferencing pointers" do
      setup do
        @pointer = mock('pointer')
        @pointer.stubs(:respond_to?).returns(true)
        @pointer.stubs(:get_bar).returns("foo")

        @type = :zoo

        @c_type = :foo
        @inferred_type = :bar
        @instance.stubs(:infer_type).returns([@c_type, @inferred_type])
      end

      should "infer the type" do
        @instance.expects(:infer_type).with(@type).returns([@c_type, @inferred_type])
        @instance.dereference_pointer(@pointer, @type)
      end

      should "call get_* method on pointer if it exists" do
        result = mock("result")
        @pointer.expects(:respond_to?).with("get_#{@inferred_type}".to_sym).returns(true)
        @pointer.expects("get_#{@inferred_type}".to_sym).with(0).returns(result)
        assert_equal result, @instance.dereference_pointer(@pointer, @type)
      end

      should "return a false bool if type is bool and failure" do
        @pointer.expects(:get_bar).returns(0)
        result = @instance.dereference_pointer(@pointer, VirtualBox::COM::T_BOOL)
        assert_equal false, result
      end

      should "return a true bool if type is bool and success" do
        @pointer.expects(:get_bar).returns(1)
        result = @instance.dereference_pointer(@pointer, VirtualBox::COM::T_BOOL)
        assert_equal true, result
      end

      should "call read_* on Util if pointer doesn't support it" do
        result = mock("result")
        @pointer.expects(:respond_to?).with("get_#{@inferred_type}".to_sym).returns(false)
        @instance.expects("read_#{@inferred_type}".to_sym).with(@pointer, @type).returns(result)
        assert_equal result, @instance.dereference_pointer(@pointer, @type)
      end
    end

    context "dereferencing pointer array" do
      setup do
        @array_pointer = mock('array_pointer')
        @array_pointer.stubs(:respond_to?).returns(true)
        @array_pointer.stubs(:get_array_of_bar)

        @pointer = mock('pointer')
        @pointer.stubs(:get_pointer).with(0).returns(@array_pointer)

        @type = :zoo
        @length = 3

        @c_type = :foo
        @inferred_type = :bar
        @instance.stubs(:infer_type).returns([@c_type, @inferred_type])
      end

      should "infer the type" do
        @instance.expects(:infer_type).with(@type).returns([@c_type, @inferred_type])
        @instance.dereference_pointer_array(@pointer, @type, @length)
      end

      should "return an empty array if count is zero" do
        assert_equal [], @instance.dereference_pointer_array(@pointer, @type, 0)
      end

      should "call get_* method on array pointer if it exists" do
        result = mock("result")
        @array_pointer.expects(:respond_to?).with("get_array_of_#{@inferred_type}".to_sym).returns(true)
        @array_pointer.expects("get_array_of_#{@inferred_type}".to_sym).with(0, @length).returns(result)
        assert_equal result, @instance.dereference_pointer_array(@pointer, @type, @length)
      end

      should "call read_* on Util if pointer doesn't support it" do
        result = mock("result")
        @array_pointer.expects(:respond_to?).with("get_array_of_#{@inferred_type}".to_sym).returns(false)
        @instance.expects("read_array_of_#{@inferred_type}".to_sym).with(@array_pointer, @type, @length).returns(result)
        assert_equal result, @instance.dereference_pointer_array(@pointer, @type, @length)
      end
    end

    context "custom pointer dereferencers" do
      context "reading unicode string" do
        setup do
          @sub_ptr = mock("sub_ptr")
          @sub_ptr.stubs(:null?).returns(false)

          @ptr = mock("pointer")
          @ptr.stubs(:get_pointer).returns(@sub_ptr)
        end

        should "return empty string for null pointer" do
          @sub_ptr.expects(:null?).returns(true)
          @instance.expects(:utf16_to_string).never
          assert_equal "", @instance.read_unicode_string(@ptr)
        end

        should "call utf16_to_string on the dereferenced pointer" do
          result = mock("result")
          @ptr.expects(:get_pointer).with(0).returns(@sub_ptr)
          @instance.expects(:utf16_to_string).with(@sub_ptr).returns(result)
          assert_equal result, @instance.read_unicode_string(@ptr)
        end
      end

      context "reading interfaces" do
        setup do
          @original_type = :foo
          @interface_klass = mock("foo_class")

          @sub_ptr = mock("sub_ptr")
          @sub_ptr.stubs(:null?).returns(false)

          @ptr = mock("pointer")
          @ptr.stubs(:get_pointer).with(0).returns(@sub_ptr)
        end

        should "convert type to a const and return instance" do
          @instance.expects(:interface_klass).with(@original_type).returns(@interface_klass)
          @interface_klass.expects(:new).with(@klass, @instance.lib, @ptr.get_pointer(0)).returns(@instance)
          assert_equal @instance, @instance.read_interface(@ptr, @original_type)
        end

        should "return nil if pointer is null" do
          @sub_ptr.expects(:null?).returns(true)
          @instance.expects(:interface_klass).never
          assert_nil @instance.read_interface(@ptr, @original_type)
        end
      end

      context "reading an enum" do
        setup do
          @enum_klass = mock("enum_class")
          @enum_klass.stubs(:[])

          @original_type = :foo
          @value = 7

          @ptr = mock("ptr")
          @ptr.stubs(:get_uint).returns(@value)
        end

        should "convert type to class and get the value" do
          result = mock("result")
          @instance.expects(:interface_klass).with(@original_type).returns(@enum_klass)
          @enum_klass.expects(:[]).with(@value).returns(result)
          assert_equal result, @instance.read_enum(@ptr, @original_type)
        end
      end

      context "reading an array of enums" do
        setup do
          @type = :foo
          @length = 3

          @pointers = []
          @length.times do |i|
            pointer = mock("pointer#{i}")
            @pointers << pointer
          end

          @pointer = mock("pointer")
          @pointer.stubs(:get_array_of_uint).returns(@pointers)

          @interface_klass = mock("foo_class")

          @instance.stubs(:read_struct).returns("foo")
        end

        should "grab the array of pointers, then convert each to a struct" do
          deref_seq = sequence("deref_seq")
          @instance.expects(:interface_klass).with(@type).returns(@interface_klass)
          @pointer.expects(:get_array_of_uint).with(0, @length).returns(@pointers).in_sequence(deref_seq)
          return_values = @pointers.collect do |pointer|
            value = "struct_of_pointer: #{pointer}"
            @interface_klass.expects(:[]).with(pointer).returns(value).in_sequence(deref_seq)
            value
          end

          assert_equal return_values, @instance.read_array_of_enum(@pointer, @type, @length)
        end
      end

      context "reading an array of interfaces" do
        setup do
          @type = :foo
          @length = 3

          @pointers = []
          @length.times do |i|
            pointer = mock("pointer#{i}")
            @pointers << pointer
          end

          @pointer = mock("pointer")
          @pointer.stubs(:get_array_of_pointer).returns(@pointers)

          @interface_klass = mock("foo_class")

          @instance.stubs(:read_struct).returns("foo")
        end

        should "grab the array of pointers, then convert each to a struct" do
          deref_seq = sequence("deref_seq")
          @instance.expects(:interface_klass).with(@type).returns(@interface_klass)
          @pointer.expects(:get_array_of_pointer).with(0, @length).returns(@pointers).in_sequence(deref_seq)
          return_values = @pointers.collect do |pointer|
            value = "struct_of_pointer: #{pointer}"
            @interface_klass.expects(:new).with(@klass, @instance.lib, pointer).returns(value).in_sequence(deref_seq)
            value
          end

          assert_equal return_values, @instance.read_array_of_interface(@pointer, @type, @length)
        end
      end

      context "reading an array of unicode strings" do
        setup do
          @type = :foo
          @length = 3

          @pointers = []
          @length.times do |i|
            pointer = mock("pointer#{i}")
            pointer.stubs(:null?).returns(false)
            @pointers << pointer
          end

          @pointer = mock("pointer")
          @pointer.stubs(:get_array_of_pointer).returns(@pointers)

          @instance.stubs(:read_struct).returns("foo")
        end

        should "grab the array of pointers, then convert each to a UTF8 string" do
          deref_seq = sequence("deref_seq")
          @pointer.expects(:get_array_of_pointer).with(0, @length).returns(@pointers).in_sequence(deref_seq)
          return_values = @pointers.collect do |pointer|
            value = "struct_of_pointer: #{pointer}"
            @instance.expects(:utf16_to_string).with(pointer).returns(value).in_sequence(deref_seq)
            value
          end

          assert_equal return_values, @instance.read_array_of_unicode_string(@pointer, @type, @length)
        end

        should "treat nil pointers as nil" do
          deref_seq = sequence("deref_seq")
          @pointer.expects(:get_array_of_pointer).with(0, @length).returns(@pointers).in_sequence(deref_seq)
          return_values = @pointers.collect do |pointer|
            pointer.expects(:null?).returns(true)
            nil
          end

          assert_equal return_values, @instance.read_array_of_unicode_string(@pointer, @type, @length)
        end
      end
    end
  end
end
