require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class DirtyTest < Test::Unit::TestCase
  class DirtyModel
    include VirtualBox::AbstractModel::Dirty
    
    def initialize
      @foo = "foo"
      @bar = "bar"
    end
    
    def foo=(value)
      set_dirty!(:foo, @foo, value)
      @foo = value
    end
    
    def bar=(value)
      set_dirty!(:bar, @bar, value)
      @bar = value
    end
  end
  
  context "dirty attributes" do
    setup do
      @model = DirtyModel.new
    end
    
    should "not be dirty initially" do
      assert !@model.changed?
    end
    
    should "be dirty after changing an attribute" do
      assert !@model.changed? # sanity
      @model.foo = "my value"
      assert @model.changed?
    end
    
    should "be able to clear dirty state" do
      assert !@model.changed?
      @model.foo = "my value"
      assert @model.changed?
      @model.clear_dirty!(:foo)
      assert !@model.changed?
    end
    
    should "show changes on specific field" do
      assert !@model.changed?
      @model.foo = "my value"
      assert @model.foo_changed?
      assert_equal ["foo", "my value"], @model.foo_change
      assert_equal "foo", @model.foo_was
    end
    
    should "show changes for the whole model" do
      assert !@model.changed?
      @model.foo = "foo2"
      @model.bar = "bar2"
      
      assert @model.changed?
      changes = @model.changes
      assert_equal 2, changes.length
      assert_equal ["foo", "foo2"], changes[:foo]
      assert_equal ["bar", "bar2"], changes[:bar]
    end
  end
end