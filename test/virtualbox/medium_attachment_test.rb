require File.join(File.dirname(__FILE__), '..', 'test_helper')

class MediumAttachmentTest < Test::Unit::TestCase
  setup do
    @interface = mock("interface")
    @interface.stubs(:medium)
    @parent = mock("parent")

    @klass = VirtualBox::MediumAttachment
  end

  context "class methods" do
    context "populating relationships" do
      setup do
        @instance = mock("instance")

        @interface.stubs(:medium_attachments).returns([])

        @klass.stubs(:device_type).returns(:all)
        @klass.stubs(:new).returns(@instance)
      end

      should "return a proxied collection" do
        result = @klass.populate_relationship(nil, @interface)
        assert result.is_a?(VirtualBox::Proxies::Collection)
      end

      should "call new for every medium if device type is all" do
        attachments = []
        @interface.stubs(:medium_attachments).returns(attachments)
        5.times { |i| attachments << mock("a#{i}") }

        expected_result = []
        new_seq = sequence("new_seq")
        attachments.each do |attachment|
          expected_value = "instance-#{attachment.inspect}"
          @klass.expects(:new).with(@parent, attachment).in_sequence(new_seq).returns(expected_value)
          expected_result << expected_value
        end

        assert_equal expected_result, @klass.populate_relationship(@parent, @interface)
      end
    end
  end

  context "initializing" do
    should "load attributes from the machine" do
      @klass.any_instance.expects(:initialize_attributes).with(@interface).once
      @klass.new(@parent, @interface)
    end
  end

  context "initializing attributes" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)
      @klass.any_instance.stubs(:populate_relationship)
    end

    should "load interface attribtues" do
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once
      @klass.new(@parent, @interface)
    end

    should "populate relationships" do
      @klass.any_instance.expects(:populate_relationship).twice
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
  end

  context "instance methods" do
    setup do
      @klass.any_instance.stubs(:initialize_attributes)

      @parent = mock("parent")
      @interface = mock("interface")
      @instance = @klass.new(@parent, @interface)
    end

    context "detaching" do
      setup do
        @machine = mock("machine")
        @session = mock("session")
        @session.stubs(:machine).returns(@machine)

        @sc = mock("storage_controller")
        @sc.stubs(:name).returns("foo")
        @instance.stubs(:storage_controller).returns(@sc)
        @instance.stubs(:port).returns(7)
        @instance.stubs(:device).returns(12)
      end

      should "open session, detach, then save" do
        det_seq = sequence("detach_seq")
        @parent.expects(:with_open_session).yields(@session).in_sequence(det_seq)
        @machine.expects(:detach_device).with(@sc.name, @instance.port, @instance.device).in_sequence(det_seq)

        @instance.detach
      end
    end

    context "destroying" do
      setup do
        @medium = mock("medium")
        @instance.stubs(:medium).returns(@medium)
      end

      should "just detach" do
        @instance.expects(:detach).once
        @instance.destroy
      end

      should "not destroy medium if nil but specified" do
        @instance.stubs(:medium).returns(nil)

        @instance.expects(:detach).once
        @medium.expects(:destroy).with(false).never
        assert_nothing_raised {
          @instance.destroy(:destroy_medium => true)
        }
      end

      should "destroy medium if specified" do
        destroy_seq = sequence("destroy_seq")
        @instance.expects(:detach).once.in_sequence(destroy_seq)
        @medium.expects(:destroy).with(false).once.in_sequence(destroy_seq)
        @instance.destroy(:destroy_medium => true)
      end

      should "destroy medium and backing store if specified" do
        destroy_seq = sequence("destroy_seq")
        @instance.expects(:detach).once.in_sequence(destroy_seq)
        @medium.expects(:destroy).with(true).once.in_sequence(destroy_seq)
        @instance.destroy(:destroy_medium => :delete)
      end
    end
  end
end