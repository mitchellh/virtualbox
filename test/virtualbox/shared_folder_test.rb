require File.join(File.dirname(__FILE__), '..', 'test_helper')

class SharedFolderTest < Test::Unit::TestCase
  setup do
    @data = {
      :sharedfoldernamemachinemapping1 => "foofolder",
      :sharedfolderpathmachinemapping1 => "/foo",
      :sharedfoldernamemachinemapping2 => "barfolder",
      :sharedfolderpathmachinemapping2 => "/bar"
    }
    
    @caller = mock("caller")
    @caller.stubs(:name).returns("foo")
  end
  
  context "populating relationships" do
    setup do
      @value = VirtualBox::SharedFolder.populate_relationship(@caller, @data)
    end

    should "create the correct amount of objects" do
      assert_equal 2, @value.length
    end
    
    should "parse the proper data" do
      value = @value[0]
      assert_equal "foofolder", value.name
      assert_equal "/foo", value.hostpath
      
      value = @value[1]
      assert_equal "barfolder", value.name
      assert_equal "/bar", value.hostpath
    end
  end
end