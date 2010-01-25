require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class CollectionTest < Test::Unit::TestCase
  setup do
    @parent = mock("parent")
    @collection = VirtualBox::Proxies::Collection.new(@parent)
  end

  should "be a subclass of Array" do
    assert @collection.is_a?(Array)
  end
  
  context "element callbacks" do
    setup do
      @item = mock("item")
    end
    
    should "not call added_to_relationship if it doesn't exist" do
      assert_nothing_raised { @collection << @item }
    end
    
    should "not call removed_from_relationship if it doesn't exist" do
      @collection << @item
      assert_nothing_raised { @collection.delete(@item) }
    end
    
    should "call added_to_relationship on the item when its added to a collection" do
      @item.expects(:added_to_relationship).with(@parent).once
      @collection << @item
    end
    
    should "call removed_from_relationship on the item when its deleted" do
      @collection << @item
      @item.expects(:removed_from_relationship).with(@parent).once
      @collection.delete(@item)
    end
    
    should "call removed_from_relationship if clear is called" do
      @collection << @item
      @item.expects(:removed_from_relationship).with(@parent).once
      @collection.clear
      assert @collection.empty?
    end
  end
end