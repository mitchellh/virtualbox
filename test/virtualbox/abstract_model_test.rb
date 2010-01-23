require File.join(File.dirname(__FILE__), '..', 'test_helper')

class AbstractModelTest < Test::Unit::TestCase
  class FakeModel < VirtualBox::AbstractModel
    attribute :foo
  end
  
  context "integrating attributable and dirty" do
    setup do
      @model = FakeModel.new
    end
    
    should "not affect dirtiness with populate_attributes" do
      assert !@model.changed?
      @model.populate_attributes({
        :foo => "foo2"
      })
      
      assert !@model.changed?
      assert_equal "foo2", @model.foo
    end
    
    should "mark dirtiness on write_attribute" do
      assert !@model.changed?
      @model.write_attribute(:foo, "foo2")
      assert @model.changed?
      assert @model.foo_changed?
      assert_equal "foo2", @model.foo
    end
  end
end