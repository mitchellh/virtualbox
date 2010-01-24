require File.join(File.dirname(__FILE__), '..', 'test_helper')

class NicTest < Test::Unit::TestCase
  context "populating relationships" do
    setup do
      @data = {
        :nic1 => "bridged",
        :nic2 => "foo",
        :nic3 => "bar"
      }
      
      @caller = mock("caller")
    end
    
    should "create the correct amount of objects" do
      value = VirtualBox::Nic.populate_relationship(@caller, @data)
      assert_equal 3, value.length
    end
  end
end