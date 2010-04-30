require File.join(File.dirname(__FILE__), '..', 'test_helper')

class StorageControllerTest < Test::Unit::TestCase
  setup do
    @interface = mock("interface")
    @parent = mock("parent")

    @klass = VirtualBox::StorageController
  end

  context "class methods" do
    context "populating relationship" do
      setup do
        # Defaulting for non-specified parameters
        @interface.stubs(:is_a?).returns(false)
      end

      should "populate array relationship if IMachine is given" do
        @interface.expects(:is_a?).with(VirtualBox::COM::Util.versioned_interface(:Machine)).returns(true)
        @klass.expects(:populate_array_relationship).once.with(@parent, @interface)
        @klass.populate_relationship(@parent, @interface)
      end

      should "populate attachment relationship if MediumAttachment is given" do
        @interface.expects(:is_a?).with(VirtualBox::MediumAttachment).returns(true)
        @klass.expects(:populate_attachment_relationship).once.with(@parent, @interface)
        @klass.populate_relationship(@parent, @interface)
      end
    end

    context "populating array (has many) relationship" do
      setup do
        @instance = mock("instance")

        @interface.stubs(:storage_controllers).returns([])

        @klass.stubs(:device_type).returns(:all)
        @klass.stubs(:new).returns(@instance)
      end

      def mock_controller(name)
        controller = mock(name)
        controller
      end

      should "return a proxied collection" do
        result = @klass.populate_array_relationship(nil, @interface)
        assert result.is_a?(VirtualBox::Proxies::Collection)
      end

      should "call new for every medium if device type is all" do
        controllers = []
        @interface.stubs(:storage_controllers).returns(controllers)
        5.times { |i| controllers << mock_controller("c#{i}") }

        expected_result = []
        new_seq = sequence("new_seq")
        controllers.each do |controller|
          expected_value = "instance-#{controller.inspect}"
          @klass.expects(:new).with(@parent, controller).in_sequence(new_seq).returns(expected_value)
          expected_result << expected_value
        end

        assert_equal expected_result, @klass.populate_array_relationship(@parent, @interface)
      end
    end

    context "populating relationship for a MediumAttachment" do
      setup do
        @controllers = []

        @machine = mock("machine")
        @machine.stubs(:storage_controllers).returns(@controllers)

        @interface.stubs(:parent).returns(@machine)
      end

      should "return nil if no controllers match" do
        assert_nil @klass.populate_attachment_relationship(@parent, @interface)
      end

      should "return the controller with matching name" do
        name = :foo
        @interface.stubs(:controller_name).returns(name)

        controller = mock("controller")
        controller.stubs(:name).returns(:foo)
        @controllers << controller

        assert_equal controller, @klass.populate_attachment_relationship(@parent, @interface)
      end
    end

    context "saving relationship" do
      should "call save on each item" do
        items = (1..5).to_a.collect do |i|
          item = mock("item-#{i}")
          item.expects(:save).once
          item
        end

        @klass.save_relationship(nil, items)
      end
    end
  end

  context "initializing" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)
    end

    should "load interface attribtues" do
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once
      @klass.new(@parent, @interface)
    end

    should "not be dirty" do
      @instance = @klass.new(@parent, @interface)
      assert !@instance.changed?
    end

    should "be existing record" do
      @instance = @klass.new(@parent, @interface)
      assert !@instance.new_record?
    end

    should "setup parent" do
      @instance = @klass.new(@parent, @interface)
      assert_equal @parent, @instance.parent
    end

    should "setup interface" do
      @instance = @klass.new(@parent, @interface)
      assert_equal @interface, @instance.interface
    end
  end

  context "instance methods" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)

      @parent = mock("parent")
      @interface = mock("interface")
      @instance = @klass.new(@parent, @interface)
    end

    context "medium attachments" do
      setup do
        @medium_attachments = []
        @parent.stubs(:medium_attachments).returns(@medium_attachments)
      end

      def mock_medium_attachment(sc)
        ma = mock("ma-#{sc.inspect}")
        ma.stubs(:storage_controller).returns(sc)
        ma
      end

      should "return all medium attachments which match the storage controller" do
        foo_ma = mock_medium_attachment(@instance)
        @medium_attachments << foo_ma
        @medium_attachments << mock_medium_attachment(:bar)

        assert_equal [foo_ma], @instance.medium_attachments
      end
    end

    context "destroying" do
      setup do
        @ma = []
        @instance.stubs(:medium_attachments).returns(@ma)

        @machine = mock("machine")
        @session = mock("session")
        @session.stubs(:machine).returns(@machine)
        @parent.stubs(:with_open_session).yields(@session)
      end

      should "remove all the attachments" do
        ma = mock("medium_attachment")
        @ma << ma

        destroy_seq = sequence("destroy_seq")
        ma.expects(:destroy).with(1,2,3).once.in_sequence(destroy_seq)
        @machine.expects(:remove_storage_controller).with(@instance.name).in_sequence(destroy_seq)

        @instance.destroy(1,2,3)
      end

      should "remove from the parent and save" do
        destroy_seq = sequence("destroy_seq")
        @machine.expects(:remove_storage_controller).with(@instance.name).in_sequence(destroy_seq)
        @instance.destroy
      end
    end
  end
end