require File.join(File.dirname(__FILE__), '..', 'test_helper')

class AbstractModelTest < Test::Unit::TestCase
  class Foo; end
  class Bar; end
  
  class FakeModel < VirtualBox::AbstractModel
    attribute :foo
    attribute :bar
    relationship :foos, Foo
    relationship :bars, Bar, :dependent => :destroy
  end
  
  context "new/existing records" do
    setup do
      @model = FakeModel.new
    end

    should "be a new record by default" do
      assert @model.new_record?
    end
    
    should "not be a new record if populate_attributes is called" do
      @model.populate_attributes({})
      assert !@model.new_record?
    end
    
    should "not be a new record after saving" do
      assert @model.new_record?
      @model.save
      assert !@model.new_record?
    end
  end
  
  context "subclasses" do
    class FakeTwoModel < FakeModel
      attribute :baz
    end
    
    setup do
      @model = FakeTwoModel.new
      @model.populate_attributes({
        :foo => "foo",
        :bar => "bar",
        :baz => "baz"
      })
    end
    
    should "have access to parents attributes" do
      assert_nothing_raised do
        assert_equal "foo", @model.foo
      end
    end
  end
  
  context "destroying" do
    setup do
      @model = FakeModel.new
    end
    
    should "call destroy_relationship only for dependent relationships" do
      Foo.expects(:destroy_relationship).never
      Bar.expects(:destroy_relationship).once
      
      @model.destroy
    end
    
    should "forward any arguments to the destroy method" do
      Bar.expects(:destroy_relationship).with(@model, anything, "HELLO").once
      @model.destroy("HELLO")
    end
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
    
    should "forward parameters through" do
      @model.expects(:save_attribute).with(:foo, "foo2", "YES").once
      Foo.expects(:save_relationship).with(@model, anything, "YES").once
      
      @model.foo = "foo2"
      @model.save("YES")
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