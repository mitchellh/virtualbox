require File.join(File.dirname(__FILE__), '..', 'test_helper')

class StorageControllerTest < Test::Unit::TestCase
  setup do
    @data = {
      :storagecontrollername0 => "foo",
      :storagecontrollermaxportcount0 => 7,
      :storagecontrollername1 => "bar",
      :storagecontrollermaxportcount1 => 4,
      :"foo-0-0" => "yay",
      :"foo-1-0" => "again",
      :"bar-0-0" => "rawr"
    }

    @caller = mock("caller")
  end

  context "saving" do
    setup do
      @value = VirtualBox::StorageController.populate_relationship(@caller, @data)
      @value = @value[0]
    end

    should "save relationship" do
      VirtualBox::AttachedDevice.expects(:save_relationship).once
      @value.save
    end
  end

  context "destroying" do
    setup do
      @value = VirtualBox::StorageController.populate_relationship(@caller, @data)
      @value = @value[0]
    end

    should "simply call destroy on each object when destroying the relationship" do
      obj_one = mock("one")
      obj_two = mock("two")

      obj_one.expects(:destroy).with("HELLO").once
      obj_two.expects(:destroy).with("HELLO").once

      VirtualBox::StorageController.destroy_relationship(self, [obj_one, obj_two], "HELLO")
    end

    should "call destroy_relationship on AttachedDevices when destroyed" do
      assert !@value.devices.empty?

      VirtualBox::AttachedDevice.expects(:destroy_relationship).once
      @value.destroy
    end
  end

  context "populating relationships" do
    should "create a collection proxy" do
      value = VirtualBox::StorageController.populate_relationship(@caller, @data)
      assert value.is_a?(VirtualBox::Proxies::Collection)
    end

    should "create the correct amount of objects" do
      value = VirtualBox::StorageController.populate_relationship(@caller, @data)
      assert_equal 2, value.length
    end

    should "use populate keys when extracting keys" do
      value = VirtualBox::StorageController.new(0, @caller, @data)
      assert_equal "foo", value.name
      assert_equal 7, value.max_ports
    end

    should "call populate attributes with the merged populate data" do
      VirtualBox::StorageController.any_instance.expects(:extract_devices).returns({ :name => "BAR" })
      value = VirtualBox::StorageController.new(0, @caller, @data)
      assert_equal "BAR", value.name
    end
  end

  context "extracting related device info" do
    setup do
      @controller = VirtualBox::StorageController.new(0, @caller, @data)
    end

    should "extract only those keys related to current controller name" do
      data = @controller.extract_devices(0, @data)
      assert data
      assert data.has_key?(:"foo-0-0")
      assert data.has_key?(:"foo-1-0")
      assert !data.has_key?(:"bar-0-0")

      data = @controller.extract_devices(1, @data)
      assert data
      assert !data.has_key?(:"foo-0-0")
      assert data.has_key?(:"bar-0-0")
    end
  end
end