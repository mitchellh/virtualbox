require File.join(File.dirname(__FILE__), '..', 'test_helper')

class NATForwardedPortTest < Test::Unit::TestCase
  setup do
    @klass = VirtualBox::NATForwardedPort

    @interface = mock("interface")
    @caller = mock("caller")
    @caller.stubs(:interface).returns(@interface)
  end

  context "validations" do
    setup do
      @collection = VirtualBox::Proxies::Collection.new(@caller)

      @port = @klass.new
      @port.name = "foo"
      @port.guestport = "22"
      @port.hostport = "2222"
      @port.added_to_relationship(@collection)
    end

    should "be valid with all fields" do
      assert @port.valid?
    end

    should "be invalid with no name" do
      @port.name = nil
      assert !@port.valid?
    end

    should "be invalid with no guest port" do
      @port.guestport = nil
      assert !@port.valid?
    end

    should "be invalid with no host port" do
      @port.hostport = nil
      assert !@port.valid?
    end

    should "be invalid if not in a relationship" do
      @port.write_attribute(:parent, nil)
      assert !@port.valid?
    end
  end

  context "with an instance" do
    setup do
      @port = @klass.new({
        :name => "foo",
        :guestport => "22",
        :hostport => "2222"
      })

      @collection = VirtualBox::Proxies::Collection.new(@caller)
      @collection << @port

      @port.clear_dirty!
    end

    context "initializing a new record" do
      setup do
        @port = @klass.new
      end

      should "be a new record" do
        assert @port.new_record?
      end

      should "not be dirty" do
        assert !@port.changed?
      end
    end

    context "saving" do
      setup do
        @interface.stubs(:add_redirect)
        @port.stubs(:destroy)
      end

      context "an existing record" do
        setup do
          @port.existing_record!
          @caller.stubs(:modify_engine)
        end

        should "not do anything and return true if its unchanged" do
          @caller.expects(:modify_engine).never
          assert @port.save
        end

        should "clear the dirty state after saving" do
          @port.name = "diff"
          @port.save
          assert !@port.changed?
        end

        should "call destroy if not a new record" do
          @port.name = "diff"
          @port.expects(:destroy).with(false).once
          @port.save
        end
      end

      context "a new record" do
        setup do
          @port.stubs(:valid?).returns(true)
          @port.new_record!
          assert @port.new_record?

          @caller.stubs(:modify_engine)
        end

        should "no longer be a new record after saving" do
          @port.save
          assert !@port.new_record?
        end

        should "not call destroy" do
          @port.expects(:destroy).never
          @port.save
        end

        should "raise a ValidationFailedException if invalid and raise_errors is true" do
          @port.expects(:valid?).returns(false)
          assert_raises(VirtualBox::Exceptions::ValidationFailedException) {
            @port.save
          }
        end

        should "add the redirect to the nat engine" do
          nat = mock("nat")
          @caller.stubs(:modify_engine).yields(nat)
          nat.expects(:add_redirect).with(@port.name,
                                                 @port.protocol,
                                                 "", @port.hostport,
                                                 "", @port.guestport)
          @port.save
        end
      end
    end

    context "destroying" do
      setup do
        @interface.stubs(:remove_redirect)
        @nat = mock("nat")
        @nat.stubs(:remove_redirect)
        @caller.stubs(:modify_engine).yields(@nat)
      end

      should "remove itself from it's collection" do
        assert @collection.include?(@port)
        @port.destroy
        assert !@collection.include?(@port)
      end

      should "not remove itself from collection if specified" do
        assert @collection.include?(@port)
        @port.destroy(false)
        assert @collection.include?(@port)
      end

      should "remove the redirect from the nat engine interface" do
        @nat.expects(:remove_redirect).with(@port.name).once
        @port.destroy
      end

      should "do nothing if the record is new" do
        @port.new_record!
        @nat.expects(:remove_redirect).never
        @port.destroy
      end

      should "be a new record after destroying" do
        @port.destroy
        assert @port.new_record?
      end
    end
  end

  context "relationships" do
    context "saving" do
      should "call #save on every object" do
        objects = []
        5.times do |i|
          object = mock("object#{i}")
          object.expects(:save).once
          objects.push(object)
        end

        @klass.save_relationship(@caller, objects)
      end
    end

    context "populating" do
      setup do
        @interface.stubs(:redirects).returns([
                                              "foo,1,,2222,,22"
                                              ])
        @objects = @klass.populate_relationship(@caller, @interface)
      end

      should "return an array of ForwardedPorts" do
        assert @objects.is_a?(VirtualBox::Proxies::Collection)
        assert @objects.all? { |o| o.is_a?(@klass) }
      end

      should "have the proper data" do
        object = @objects.first
        assert_equal 22, object.guestport
        assert_equal 2222, object.hostport
        assert_equal :tcp, object.protocol
        assert_equal @objects, object.parent_collection
      end

      should "be existing records" do
        assert !@objects.first.new_record?
      end
    end
  end
end
