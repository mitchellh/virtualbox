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
  
  context "populating relationships" do
    should "create the correct amount of objects" do
      value = VirtualBox::StorageController.populate_relationship(@caller, @data)
      assert_equal 2, value.length
    end
    
    should "use populate keys when extracting keys" do
      value = VirtualBox::StorageController.new(0, @data)
      assert_equal "foo", value.name
      assert_equal 7, value.max_ports
    end
  end
  
  context "extracting related device info" do
    setup do
      @controller = VirtualBox::StorageController.new(0, @data)
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