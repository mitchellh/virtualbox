require File.join(File.dirname(__FILE__), '..', 'test_helper')

class AbstractModelTest < Test::Unit::TestCase
  class Foo
    def self.populate_relationship(caller, data); end
    def self.save_relationship(caller, data); end
  end
  
  class FakeModel < VirtualBox::AbstractModel
    attribute :foo
    attribute :bar
    relationship :foos, Foo
  end
  
  context "saving" do
    setup do
      @model = FakeModel.new
      @model.populate_attributes({
        :foo => "foo",
        :bar => "bar"
      })
    end
    
    should "call save_attribute for only attributes which have changed" do
      @model.foo = "foo2"
      assert @model.foo_changed?
      assert !@model.bar_changed?
      @model.expects(:save_attribute).with(:foo, "foo2").once
      @model.save
    end
    
    should "call save_relationships" do
      @model.expects(:save_relationships).once
      @model.save
    end
    
    should "clear dirty state once saved" do
      @model.foo = "foo2"
      assert @model.foo_changed?
      @model.save
      assert !@model.foo_changed?
    end
  end
  
  context "populating relationships and attributes" do
    setup do
      @model = FakeModel.new
    end
    
    should "populate relationships at the same time as attributes" do
      Foo.expects(:populate_relationship).once
      @model.populate_attributes({})
    end
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