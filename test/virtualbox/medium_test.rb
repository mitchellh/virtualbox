require File.join(File.dirname(__FILE__), '..', 'test_helper')

class MediumTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::Medium
    @imedium = mock("IMedium")
    @interface = @imedium
    @imedium.stubs(:refresh_state)
  end

  context "class methods" do
    context "device type" do
      should "be all on the medium" do
        assert_equal :all, @klass.device_type
      end
    end

    context "populating relationships" do
      setup do
        @caller = mock("caller")
      end

      should "call populate_array_relationship for arrays" do
        @klass.expects(:populate_array_relationship).with(@caller, []).once
        @klass.populate_relationship(@caller, [])
      end

      should "call populate_single_relationship for non-arrays" do
        @klass.expects(:populate_single_relationship).with(@caller, nil).once
        @klass.populate_relationship(@caller, nil)
      end
    end

    context "populating array relationship" do
      setup do
        @instance = mock("instance")

        @klass.stubs(:device_type).returns(:all)
        @klass.stubs(:new).returns(@instance)
      end

      def mock_medium(device_type)
        medium = mock("medium")
        medium.stubs(:device_type).returns(device_type)
        medium
      end

      should "return a proxied collection" do
        result = @klass.populate_array_relationship(nil, [])
        assert result.is_a?(VirtualBox::Proxies::Collection)
      end

      should "call new for every medium if device type is all" do
        media = []
        5.times { |i| media << mock_medium("m#{i}") }

        expected_result = []
        new_seq = sequence("new_seq")
        media.each do |medium|
          expected_value = "instance-#{medium.inspect}"
          @klass.expects(:new).with(medium).in_sequence(new_seq).returns(expected_value)
          expected_result << expected_value
        end

        assert_equal expected_result, @klass.populate_array_relationship(nil, media)
      end

      should "ignore non-matching devices if device_type is not :all" do
        @klass.stubs(:device_type).returns(:foo)

        media = [mock_medium(:foo), mock_medium(:bar)]
        result = @klass.populate_array_relationship(nil, media)
        assert_equal 1, result.length
      end
    end

    context "populating a single relationship" do
      setup do
        @subclasses = []
        @klass.stubs(:subclasses).returns(@subclasses)
        @imedium.stubs(:get_device_type).returns(nil)
      end

      def mock_subclass(device_type)
        subclass = mock("subclass")
        subclass.stubs(:device_type).returns(device_type)
        subclass
      end

      should "instantiate the matching subclass" do
        type = :foo
        result = mock("result")
        matching = mock_subclass(type)
        matching.expects(:new).with(@imedium).once.returns(result)
        @subclasses << matching
        @imedium.stubs(:device_type).returns(type)

        assert_equal result, @klass.populate_single_relationship(nil, @imedium)
      end

      should "return a Medium if nothing matches" do
        result = mock("result")
        @klass.expects(:new).with(@imedium).returns(result)
        assert_equal result, @klass.populate_single_relationship(nil, @imedium)
      end

      should "return nil if medium given is nil" do
        @klass.expects(:new).never
        assert_nil @klass.populate_single_relationship(nil, nil)
      end
    end
  end

  context "initializing" do
    should "load attributes from the machine" do
      @klass.any_instance.expects(:initialize_attributes).with(@interface).once
      @klass.new(@interface)
    end

    should "set the interface as the interface attribute" do
      @klass.any_instance.stubs(:initialize_attributes)
      instance = @klass.new(@interface)
      assert_equal @interface, instance.interface
    end
  end

  context "initializing attributes" do
    setup do
      @interface.stubs(:refresh_state)
      @klass.any_instance.stubs(:load_interface_attributes)
    end

    should "refresh state then load interface attribtues" do
      init_seq = sequence("init_seq")
      @interface.expects(:refresh_state).in_sequence(init_seq)
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once.in_sequence(init_seq)
      @klass.new(@interface)
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

  context "with an instance" do
    setup do
      @klass.any_instance.stubs(:initialize_attributes)
      @instance = @klass.new(@imedium)
    end

    context "filename" do
      setup do
        @location = "/foo/bar/baz.rb"
        @instance.stubs(:location).returns(@location)
      end

      should "return the basename of the location" do
        assert_equal File.basename(@location), @instance.filename
      end
    end

    context "destroy storage" do
      should "delete the storage then wait for it to complete" do
        progress = mock("progress")

        @imedium.expects(:delete_storage).once.returns(progress)
        progress.expects(:wait_for_completion).with(-1).once

        @instance.destroy_storage
      end
    end

    context "destroying" do
      should "just close the medium if first argument is not specified" do
        @instance.expects(:destroy_storage).never
        @imedium.expects(:close).once
        @instance.destroy
      end

      should "destroy the storage if first argument is true" do
        @instance.expects(:destroy_storage).once
        @instance.destroy(true)
      end
    end
  end
end