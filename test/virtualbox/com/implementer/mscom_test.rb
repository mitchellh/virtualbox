require File.expand_path("../../../../test_helper", __FILE__)

class COMImplementerMSCOMTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::COM::Implementer::MSCOM
    @interface = mock("interface")
    @lib = mock("lib")
    @object = mock("object")
  end

  context "initializing" do
    should "make the lib base and object accessible" do
      instance = @klass.new(@interface, @lib, @object)
      assert_equal @lib, instance.lib
      assert_equal @object, instance.object
    end
  end

  context "with an instance" do
    setup do
      @instance = @klass.new(@interface, @lib, @object)
    end

    context "spec to formal argument list" do
      should "replace primitives with their types" do
        assert_equal [7], @instance.spec_to_args([:int], [7])
      end

      should "replace booleans with 1/0" do
        bool = VirtualBox::COM::T_BOOL
        assert_equal [1,0], @instance.spec_to_args([bool, bool], [true, false])
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

      should "ignore out parameters" do
        spec = [[:out, :hey], :int]
        args = [7]

        assert_equal [7], @instance.spec_to_args(spec, args)
      end
    end

    context "reading a property" do
      context "with ruby 1.8" do
        setup do
          @instance.stubs(:ruby_version).returns(1.8)
        end

        should "read the property on the object and return it" do
          name = :foo_bar
          value = mock("value")
          result = mock("result")
          opts = { :value_type => :foo }
          @object.expects(:[]).with('FooBar').once.returns(value)
          @instance.expects(:returnable_value).with(value, opts[:value_type]).returns(result)

          assert_equal result, @instance.read_property(name, opts)
        end
      end

      context "with ruby 1.9" do
        setup do
          @instance.stubs(:ruby_version).returns(1.9)
        end

        should "read the property on the object and return it" do
          name = :foo_bar
          value = mock("value")
          result = mock("result")
          opts = { :value_type => :foo }
          @object.expects(:FooBar).once.returns(value)
          @instance.expects(:returnable_value).with(value, opts[:value_type]).returns(result)

          assert_equal result, @instance.read_property(name, opts)
        end
      end
    end

    context "writing a property" do
      context "on ruby 1.8" do
        setup do
          @instance.stubs(:ruby_version).returns(1.8)
        end

        should "convert the args and set it on the object" do
          name = :foo_bar
          opts = { :value_type => :foo }
          @instance.expects(:spec_to_args).with([:foo], [:value]).returns([:modified])
          @object.expects(:[]=).with('FooBar', :modified).once

          @instance.write_property(name, :value, opts)
        end
      end

      context "on ruby 1.9" do
        setup do
          @instance.stubs(:ruby_version).returns(1.9)
        end

        should "convert the args and set it on the object" do
          name = :foo_bar
          opts = { :value_type => :foo }
          @instance.expects(:spec_to_args).with([:foo], [:value]).returns([:modified])
          @object.expects(:FooBar=).with(:modified).once

          @instance.write_property(name, :value, opts)
        end
      end
    end

    context "calling a function" do
      should "send the method and args to the object and return the value" do
        name = :foo_bar
        args = [1,2,3]
        formal_args = [4,5,6]
        result = mock("result")
        value = mock("value")
        opts = { :value_type => :foo, :spec => :foo }
        @object.expects(:send).with('FooBar', *formal_args).once.returns(value)
        @instance.expects(:spec_to_args).with(opts[:spec], args).returns(formal_args)
        @instance.expects(:returnable_value).with(value, opts[:value_type]).returns(result)

        assert_equal result, @instance.call_function(name, args, opts)
      end
    end

    context "returnable values" do
      should "just return nil if type is nil" do
        assert_nil @instance.returnable_value(7, nil)
      end

      should "just return nil if type is void" do
        assert_nil @instance.returnable_value(7, :void)
      end

      should "infer the type then attempt to read that type" do
        @instance.expects(:infer_type).with(:bar).returns([nil, :foo])
        @instance.expects(:read_foo).with(7, :bar).once
        @instance.returnable_value(7, :bar)
      end

      should "infer type and call array method for arrays" do
        @instance.expects(:infer_type).with(:bar).returns([nil, :foo])
        @instance.expects(:read_array_of_foo).with(7, [:bar]).once
        @instance.returnable_value(7, [:bar])
      end

      should "return the value of the read method" do
        result = mock("result")
        @instance.expects(:infer_type).with(:bar).returns([nil, :foo])
        @instance.expects(:read_foo).with(7, :bar).once.returns(result)
        assert_equal result, @instance.returnable_value(7, :bar)
      end
    end

    context "reading primitive values" do
      # Yes, it typically avoid meta-programming, but this is such a
      # repetitive and simple case that I am doing it
      [:ushort, :uint, :ulong, :int, :long].each do |prim|
        should "read #{prim} and convert to int" do
          assert_equal 7, @instance.send("read_#{prim}".to_sym, "7", prim)
        end
      end

      should "return strings as is" do
        assert_equal "foo", @instance.read_unicode_string("foo", :unicode_string)
      end

      should "read char as a boolean value" do
        assert_equal true, @instance.read_char('1', :char)
        assert_equal false, @instance.read_char('0', :char)
        assert_equal true, @instance.read_char(1, :char)
        assert_equal false, @instance.read_char(0, :char)
      end
    end

    context "reading enums" do
      setup do
        @interface_klass = mock("klass")

        @type = :foo
        @value = :bar
        @result = mock("result")
      end

      should "index the value on the interface class" do
        @instance.expects(:interface_klass).with(@type).returns(@interface_klass)
        @interface_klass.expects(:[]).with(@value).returns(@result)

        assert_equal @result, @instance.read_enum(@value, @type)
      end
    end

    context "reading interfaces" do
      setup do
        @interface_klass = mock("klass")

        @type = :foo
        @value = :bar
        @result = mock("result")
      end

      should "instantiate the klass properly" do
        @instance.expects(:interface_klass).with(@type).returns(@interface_klass)
        @interface_klass.expects(:new).with(@instance.class, @instance.lib, @value).returns(@result)

        assert_equal @result, @instance.read_interface(@value, @type)
      end
    end

    context "reading an array of strings" do
      should "just return as is" do
        assert_equal ["foo", "bar"], @instance.read_array_of_unicode_string(["foo", "bar"], :unicode_string)
      end
    end

    context "read array of interface" do
      setup do
        @interface_klass = mock("klass")

        @type = :foo
        @value = [:foo, nil]
        @result = mock("result")
      end

      should "instantiate the klass properly for non-nil values" do
        @instance.expects(:interface_klass).with(@type).returns(@interface_klass)
        @interface_klass.expects(:new).with(@instance.class, @instance.lib, @value[0]).returns(@result)

        assert_equal [@result, nil], @instance.read_array_of_interface(@value, [@type])
      end
    end
  end
end
