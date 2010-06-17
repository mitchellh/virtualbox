require File.join(File.dirname(__FILE__), '..', 'test_helper')

class NATEngineTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::NATEngine
    @interface = mock("interface")
    @parent = mock("parent")
  end

  context "initializing" do
    should "load attributes from the machine" do
      @klass.any_instance.expects(:initialize_attributes).with(@parent, @interface).once
      @klass.new(@parent, @interface)
    end
  end

  context "initializing attributes" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)
      @klass.any_instance.stubs(:populate_relationships)

      @instance = @klass.new(@parent, @interface)
    end

    should "load interface attribtues" do
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once
      @klass.new(@parent, @interface)
    end

    should "setup the parent" do
      assert_equal @parent, @instance.parent
    end

    should "setup the interface" do
      assert_equal @interface, @instance.interface
    end

    should "not be dirty" do
      assert !@instance.changed?
    end

    should "be existing record" do
      assert !@instance.new_record?
    end
  end

  context "class methods" do
    context "populating relationship" do
      should "return nil if the interface is nil" do
        assert_nil @klass.populate_relationship(@parent, nil)
      end

      should "return an initialized NATEngine" do
        @klass.any_instance.stubs(:load_interface_attributes)
        @klass.any_instance.stubs(:populate_relationships)
        result = @klass.populate_relationship(@parent, @interface)
        assert result.is_a?(@klass)
        assert_equal @parent, result.parent
        assert_equal @interface, result.interface
      end
    end

    context "saving relationship" do
      should "call save on each item" do
        item = mock("item")
        item.expects(:save)
        @klass.save_relationship(nil, item)
      end
    end
  end

  context "instance methods" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)
      @klass.any_instance.stubs(:populate_relationships)
      @instance = @klass.new(@parent, @interface)
    end

    context "saving" do
      setup do
        @engine = mock("engine")
        @instance.stubs(:modify_engine).yields(@engine)
      end

      should "save the interface attributes and relationships" do
        @instance.expects(:save_changed_interface_attributes).with(@engine).once
        @instance.expects(:save_relationships).once
        @instance.save
      end
    end

    context "modify engine" do
      setup do
        @adapter = mock("adapter")
        @adapter.stubs(:nat_driver).returns(mock("nat_driver"))
        @parent.stubs(:modify_adapter).yields(@adapter)
      end

      should "yield the NAT engine" do
        @instance.modify_engine do |engine|
          assert_equal @adapter.nat_driver, engine
        end
      end
    end
  end
end
