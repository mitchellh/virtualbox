require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ForwardedPortTest < Test::Unit::TestCase
  setup do
    @nic = mock("nic")
    @nic.stubs(:adapter_type).returns(:foo)
    @nics = [@nic]

    @caller = mock("caller")
    @caller.stubs(:network_adapters).returns(@nics)

    @interface = mock("interface")
  end

  context "validations" do
    setup do
      @collection = VirtualBox::Proxies::Collection.new(@caller)

      @port = VirtualBox::ForwardedPort.new
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
      @port = VirtualBox::ForwardedPort.new({
        :name => "foo",
        :guestport => "22",
        :hostport => "2222"
      })

      @collection = VirtualBox::Proxies::Collection.new(@caller)
      @collection << @port

      @port.clear_dirty!

      @ed = mock("extradata")
      @ed.stubs(:[]=)
      @ed.stubs(:save)
      @ed.stubs(:delete)
      @caller.stubs(:extra_data).returns(@ed)
    end

    context "device" do
      setup do
        @port.new_record!
        @port.added_to_relationship(@collection)
      end

      should "return the value set if it was set" do
        @port.device = "foo"
        assert_equal "foo", @port.device
      end

      should "return the default if parent is nil" do
        @port.expects(:parent).returns(nil)
        assert_equal "pcnet", @port.device
      end

      should "return the default if the record is existing" do
        @nic.expects(:adapter_type).never
        @port.existing_record!
        assert_equal "pcnet", @port.device
      end

      should "return pcnet if card is a Am79C970A type" do
        @nic.expects(:adapter_type).returns(:Am79C970A)
        assert_equal "pcnet", @port.device
      end

      should "return pcnet if card is a Am79C973 type" do
        @nic.expects(:adapter_type).returns(:Am79C973)
        assert_equal "pcnet", @port.device
      end

      should "return e1000 if card is a 82540EM type" do
        @nic.expects(:adapter_type).returns(:I82540EM)
        assert_equal "e1000", @port.device
      end

      should "return e1000 if card is a 82543GC type" do
        @nic.expects(:adapter_type).returns(:I82543GC)
        assert_equal "e1000", @port.device
      end

      should "return e1000 if card is a 82545EM type" do
        @nic.expects(:adapter_type).returns(:I82545EM)
        assert_equal "e1000", @port.device
      end
    end

    context "saving" do
      context "an existing record" do
        setup do
          @port.existing_record!
        end

        should "not do anything and return true if its unchanged" do
          @caller.expects(:extra_data).never
          assert @port.save
        end

        should "clear the dirty state after saving" do
          @port.name = "diff"
          @port.save
          assert !@port.changed?
        end

        should "call destroy if the name changed" do
          @port.name = "diff"
          @port.expects(:destroy).once
          @port.save
        end

        should "not call destroy if the name didn't change" do
          assert !@port.name_changed?
          @port.expects(:destroy).never
          @port.save
        end
      end

      context "a new record" do
        setup do
          @port.stubs(:valid?).returns(true)
          assert @port.new_record!
        end

        should "no longer be a new record after saving" do
          @port.save
          assert !@port.new_record?
        end

        should "raise a ValidationFailedException if invalid and raise_errors is true" do
          @port.expects(:valid?).returns(false)
          assert_raises(VirtualBox::Exceptions::ValidationFailedException) {
            @port.save
          }
        end

        should "call save on the extra_data" do
          @ed = mock("ed")
          @ed.expects(:[]=).times(3)
          @ed.expects(:save).once
          @caller.expects(:extra_data).times(4).returns(@ed)
          @port.save
        end
      end
    end

    context "key prefix" do
      should "return a proper key prefix constructed with the attributes" do
        assert_equal "VBoxInternal\/Devices\/#{@port.device}\/#{@port.instance}\/LUN#0\/Config\/#{@port.name}\/", @port.key_prefix
      end

      should "return with previous name if parameter is true" do
        @port.name = "diff"
        assert @port.name_changed?
        assert_equal "VBoxInternal\/Devices\/#{@port.device}\/#{@port.instance}\/LUN#0\/Config\/#{@port.name_was}\/", @port.key_prefix(true)
      end

      should "not use previous name if parameter is true and name didn't change" do
        assert !@port.name_changed?
        assert_equal "VBoxInternal\/Devices\/#{@port.device}\/#{@port.instance}\/LUN#0\/Config\/#{@port.name}\/", @port.key_prefix(true)
      end
    end

    context "destroying" do
      setup do
        @port.existing_record!
      end

      should "remove itself from it's collection" do
        assert @collection.include?(@port)
        @port.destroy
        assert !@collection.include?(@port)
      end

      should "call delete on the extra data for each key" do
        @ed = mock("ed")
        @ed.expects(:delete).times(3)
        @caller.expects(:extra_data).times(3).returns(@ed)
        @port.destroy
      end

      should "do nothing if the record is new" do
        @port.new_record!
        @caller.expects(:extra_data).never
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

        VirtualBox::ForwardedPort.save_relationship(@caller, objects)
      end
    end

    context "populating" do
      setup do
        @caller.stubs(:extra_data).returns({
          "invalid" => "7",
          "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/GuestPort" => "22",
          "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/HostPort" => "2222",
          "VBoxInternal/Devices/pcnet/0/LUN#0/Config/guestssh/Protocol" => "TCP"
        })

        @objects = VirtualBox::ForwardedPort.populate_relationship(@caller, {})
      end

      should "return an array of ForwardedPorts" do
        assert @objects.is_a?(VirtualBox::Proxies::Collection)
        assert @objects.all? { |o| o.is_a?(VirtualBox::ForwardedPort) }
      end

      should "have the proper data" do
        object = @objects.first
        assert_equal "22", object.guestport
        assert_equal "2222", object.hostport
        assert_equal "TCP", object.protocol
        assert_equal @objects, object.parent_collection
      end

      should "be existing records" do
        assert !@objects.first.new_record?
      end
    end
  end
end
