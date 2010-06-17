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
  end
end
