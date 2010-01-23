require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ModelTest < Test::Unit::TestCase
  class FakeModel < VirtualBox::Model
    attribute :foo
    attribute :bar
    
    def initialize
      super
      
      populate_attributes({
        :foo => "foo",
        :bar => "bar"
      })
    end
  end
  
  context "populating attributes" do
    setup do
      @model = FakeModel.new
    end
    
    should "write all valid attributes" do
      new_attributes = {
        :foo => "zxcv",
        :bar => "qwerty"
      }
      
      @model.populate_attributes(new_attributes)
      new_attributes.each do |k,v|
        assert_equal v, @model.send(k)
      end
    end
    
    should "not affect dirty state" do
      assert !@model.changed?
      @model.populate_attributes({ :foo => "HEY" })
      assert !@model.changed?
      assert_equal "HEY", @model.foo
    end
  end
  
  context "reading and writing attributes" do
    setup do
      @model = FakeModel.new
      @checkstring = "HEY"
    end
    
    should "be able to write defined attributes" do
      assert_nothing_raised {
        @model.foo = @check_string
      }
    end
    
    should "be able to read defined attributes" do
      assert_nothing_raised {
        assert_equal "foo", @model.foo
      }
    end
    
    should "raise an error if attempting to write an undefined attribute" do
      assert_raises(NoMethodError) { @model.baz = @check_string }
    end
    
    should "raise an error if attempting to read an undefined attribute" do
      assert_raises(NoMethodError) { @model.baz }
    end
  end
  
  context "dirty attributes" do
    setup do
      @model = FakeModel.new
    end
    
    should "not be dirty initially" do
      assert !@model.changed?
    end
    
    should "be dirty after changing an attribute" do
      assert !@model.changed? # sanity
      @model.foo = "my value"
      assert @model.changed?
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