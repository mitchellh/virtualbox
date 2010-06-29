require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class CollectionTest < Test::Unit::TestCase
  setup do
    @parent = mock("parent")
    @item_klass = mock("item_klass")
    @klass = VirtualBox::Proxies::Collection
    @collection = @klass.new(@parent, @item_klass)
  end

  should "be a subclass of Array" do
    assert @collection.is_a?(Array)
  end

  context "creating" do
    should "call create on the item klass and put it in the array" do
      result = mock("result")
      @item_klass.expects(:create).with(@collection).returns(result)
      @collection.create
      assert @collection.include?(result)
    end

    should "pass in any additional arguments if given" do
      blah = mock("some blah")
      @collection = @klass.new(@parent, @item_klass, blah)
      @item_klass.expects(:create).with(@collection, blah).returns(nil)
      @collection.create
    end

    should "pass in additional arguments from the call" do
      result = mock("result")
      @item_klass.expects(:create).with(@collection, :foo).returns(result)
      assert_equal result, @collection.create(:foo)
    end

    should "do nothing if klass doesn't respond to create" do
      previous_length = @collection.length
      assert_nothing_raised { assert_nil @collection.create }
      assert_equal previous_length, @collection.length
    end
  end

  context "errors" do
    should "return the errors of all the elements" do
      errors = []
      3.times do |i|
        error = "error#{i}"
        item = mock("item")
        item.stubs(:errors).returns(error)
        errors << error
        @collection << item
      end

      assert_equal errors, @collection.errors
    end
  end

  context "element callbacks" do
    setup do
      @item = mock("item")
    end

    context "<<" do
      should "not call added_to_relationship if it doesn't exist" do
        assert_nothing_raised { @collection << @item }
      end

      should "call added_to_relationship on the item when its added to a collection" do
        @item.expects(:added_to_relationship).with(@collection).once
        @collection << @item
      end
    end

    context "delete" do
      should "not call removed_from_relationship if it doesn't exist" do
        @collection << @item
        assert_nothing_raised { @collection.delete(@item) }
      end

      should "call removed_from_relationship on the item when its deleted" do
        @collection << @item
        @item.expects(:removed_from_relationship).with(@collection).once
        @collection.delete(@item)
      end

      should "not call removed_from_relationship if no_callback is set" do
        @collection << @item
        @item.expects(:removed_from_relationship).never
        @collection.delete(@item, true)
      end
    end

    context "clearing" do
      should "call removed_from_relationship if clear is called" do
        @collection << @item
        @item.expects(:removed_from_relationship).with(@collection).once
        @collection.clear
        assert @collection.empty?
      end
    end
  end
end
