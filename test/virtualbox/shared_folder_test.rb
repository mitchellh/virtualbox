require File.expand_path("../../test_helper", __FILE__)

class SharedFolderTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::SharedFolder
    @interface = mock("interface")
    @parent = mock("parent")
  end

  context "initializing" do
    should "load attributes from the machine" do
      @klass.any_instance.expects(:initialize_attributes).with(@interface).once
      @klass.new(@interface)
    end

    should "not load attributes if new record" do
      @klass.any_instance.expects(:initialize_attributes).never
      @klass.new
    end
  end

  context "initializing attributes" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)
      @klass.any_instance.stubs(:populate_relationships)
    end

    should "load interface attribtues" do
      @klass.any_instance.expects(:load_interface_attributes).with(@interface).once
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

  context "class methods" do
    context "populating relationship" do
      setup do
        @instance = mock("instance")

        @klass.stubs(:new).returns(@instance)

        @collection = []
        @interface.stubs(:shared_folders).returns(@collection)
      end

      should "return a proxied collection" do
        result = @klass.populate_relationship(nil, @interface)
        assert result.is_a?(VirtualBox::Proxies::Collection)
      end

      should "call new for every shared folder" do
        5.times { |i| @collection << mock("#{i}") }

        expected_result = []
        new_seq = sequence("new_seq")
        @collection.each do |item|
          expected_value = "instance-#{item.inspect}"
          @klass.expects(:new).with(item).in_sequence(new_seq).returns(expected_value)
          expected_result << expected_value
        end

        assert_equal expected_result, @klass.populate_relationship(nil, @interface)
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

  context "instance methods" do
    setup do
      @klass.any_instance.stubs(:load_interface_attributes)
      @instance = @klass.new(@interface)
      @instance.stubs(:parent_machine).returns(@parent)
      @collection = VirtualBox::Proxies::Collection.new(@parent)
      @collection << @instance

      @parent_interface = mock("interface")
      @parent.stubs(:interface).returns(@parent_interface)

      @name = "foo"
      @machine = mock("machine")
      @machine.stubs(:remove_shared_folder).with(@name)

      @session = mock("session")
      @session.stubs(:machine).returns(@machine)

      @parent.stubs(:with_open_session).yields(@session)
    end

    context "saving" do
      setup do
        @instance.stubs(:valid?).returns(true)
      end

      should "do nothing if its not a new record and its not changed" do
        assert !@instance.new_record?
        assert !@instance.changed?
        assert @instance.save
      end

      should "raise an exception if invalid" do
        @instance.name = "foo_bar" # To set the changed flag
        @instance.expects(:valid?).returns(false)

        assert_raises(VirtualBox::Exceptions::ValidationFailedException) {
          @instance.save
        }
      end

      should "destroy then create" do
        @instance.name = "foo_bar"
        assert !@instance.new_record? # sanity

        save_seq = sequence("save_seq")
        @instance.expects(:destroy).with(false).once.in_sequence(save_seq)
        @instance.expects(:create).once.in_sequence(save_seq)

        @instance.save
      end

      should "just create (not destroy) if its a new record" do
        @instance.new_record!

        @instance.expects(:destroy).never
        @instance.expects(:create).once

        @instance.save
      end
    end

    context "creating" do
      setup do
        @instance.new_record!

        @instance.name = "foo"
        @instance.host_path = "/bar"
        @instance.writable = true

        @machine.stubs(:create_shared_folder)
      end

      should "do nothing if its an existing record" do
        @instance.existing_record!
        @machine.expects(:create_shared_folder).never
        @instance.create
      end

      should "create the shared folder" do
        create_seq = sequence("create_seq")
        @machine.expects(:create_shared_folder).with(@instance.name, @instance.host_path, @instance.writable).once.in_sequence(create_seq)
        @instance.create
      end

      should "not be a new record after saving" do
        assert @instance.new_record?
        @instance.create
        assert !@instance.new_record?
      end

      should "not be dirty after saving" do
        assert @instance.changed?
        @instance.create
        assert !@instance.changed?
      end
    end

    context "destroying" do
      setup do
        @name = "foo"
        @instance.stubs(:name).returns(@name)
        @machine.stubs(:remove_shared_folder).with(@name)
      end

      should "remove itself from it's collection" do
        assert @collection.include?(@instance)
        @instance.destroy
        assert !@collection.include?(@instance)
      end

      should "not remove itself from it's collection if specified" do
        assert @collection.include?(@instance)
        @instance.destroy(false)
        assert @collection.include?(@instance)
      end

      should "destroy the shared folder on the parent" do
        destroy_seq = sequence("destroy_seq")
        @machine.expects(:remove_shared_folder).with(@name).in_sequence(destroy_seq)

        @instance.destroy
      end

      should "mark as a new record" do
        assert !@instance.new_record?
        @instance.destroy
        assert @instance.new_record?
      end
    end
  end
end
