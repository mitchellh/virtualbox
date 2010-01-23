require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class AttributableTest < Test::Unit::TestCase
  class AttributeModel
    include VirtualBox::AbstractModel::Attributable
    
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
  
  context "attribute options" do
    context "custom populate keys" do
      class CustomPopulateModel < AttributeModel
        attribute :foo, :populate_key => :foo_key
      end
      
      setup do
        @model = CustomPopulateModel.new
      end
      
      should "use the populate key instead of the attribute name" do
        @model.populate_attributes({
          :foo => "not me!",
          :foo_key => "bar"
        })
        
        assert_equal "bar", @model.foo
      end
    end
    
    context "readonly attributes" do
      class ReadonlyModel < AttributeModel
        attribute :foo, :readonly => :readonly
        
        def initialize
          super
          populate_attributes({ :foo => "foo" })
        end
      end
      
      setup do
        @model = ReadonlyModel.new
      end
      
      should "be readonly" do
        assert @model.readonly_attribute?(:foo)
      end
      
      should "allow reading" do
        assert_equal "foo", @model.foo
      end
      
      should "not allow writing" do
        assert_raises(NoMethodError) { @model.foo = "YO" }
      end
    end
  end
  
  context "populating attributes" do
    setup do
      @model = AttributeModel.new
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
  end
  
  context "reading and writing attributes" do
    setup do
      @model = AttributeModel.new
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
end