require File.expand_path("../../test_helper", __FILE__)

class VirtualSystemDescriptionTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::VirtualSystemDescription
    @interface = mock("interface")
  end

  context "class methods" do
    context "populating relationship" do
      setup do
        @instance = mock("instance")

        @klass.stubs(:new).returns(@instance)
      end

      should "return a proxied collection" do
        result = @klass.populate_relationship(nil, [])
        assert result.is_a?(VirtualBox::Proxies::Collection)
      end

      should "call new for every description" do
        interfaces = []
        5.times { |i| interfaces << mock("i#{i}") }

        expected_result = []
        new_seq = sequence("new_seq")
        interfaces.each do |interface|
          expected_value = "instance-#{interface.inspect}"
          @klass.expects(:new).with(interface).in_sequence(new_seq).returns(expected_value)
          expected_result << expected_value
        end

        assert_equal expected_result, @klass.populate_relationship(nil, interfaces)
      end
    end
  end

  context "initializing" do
    should "load attributes from the machine" do
      @klass.any_instance.expects(:initialize_attributes).with(@interface).once
      @klass.new(@interface)
    end
  end

  context "initializing attributes" do
    setup do
      @interface.stubs(:get_values_by_type).returns(nil)
    end

    should "not be dirty" do
      @instance = @klass.new(@interface)
      assert !@instance.changed?
    end

    should "be existing record" do
      @instance = @klass.new(@interface)
      assert !@instance.new_record?
    end
  end
end
