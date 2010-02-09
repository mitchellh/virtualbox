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
      @value = VirtualBox::StorageController.populate_relationship(@caller, mock_xml_doc)
      @value = @value[0]
    end

    should "save relationship" do
      VirtualBox::AttachedDevice.expects(:save_relationship).once
      @value.save
    end
  end

  context "destroying" do
    setup do
      @value = VirtualBox::StorageController.populate_relationship(@caller, mock_xml_doc)
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
    setup do
      @sc = mock_xml_doc.css("StorageControllers StorageController").first
    end

    should "create a collection proxy" do
      value = VirtualBox::StorageController.populate_relationship(@caller, mock_xml_doc)
      assert value.is_a?(VirtualBox::Proxies::Collection)
    end

    should "create the correct amount of objects" do
      value = VirtualBox::StorageController.populate_relationship(@caller, mock_xml_doc)
      assert_equal 1, value.length
    end

    should "use populate keys when extracting keys" do
      value = VirtualBox::StorageController.new(0, @caller, @sc)
      assert_equal "foo", value.name
      assert_equal "2", value.ports
      assert_equal "PIIX4", value.type
    end
  end
end