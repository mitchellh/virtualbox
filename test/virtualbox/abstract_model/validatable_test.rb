require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class ValidatableTest < Test::Unit::TestCase
  class ValidatableModel
    include VirtualBox::AbstractModel::Validatable
    
    attr_accessor :foos
    attr_accessor :bars
  end
  
  context "errors" do
    setup do
      @model = ValidatableModel.new
    end
  
    should "have no errors by default" do
      assert @model.errors.empty?
    end
    
    should "be able to add errors" do
      @model.add_error(:foo, "is blank")
      assert !@model.errors.empty?
      assert !@model.errors[:foo].nil?
      assert_equal "is blank", @model.errors[:foo].first
    end
    
    should "be able to add multiple errors" do
      @model.add_error(:foo, "foo")
      @model.add_error(:foo, "bar")
      assert !@model.errors.empty?
      assert !@model.errors[:foo].nil?
      assert_equal 2, @model.errors[:foo].length
    end
    
    should "be able to clear errors" do
      @model.add_error(:foo, "foo")
      assert !@model.errors.empty?
      @model.clear_errors
      assert @model.errors.empty?
    end
  end
  
  context "validity" do
    setup do
      @model = ValidatableModel.new
    end
    
    should "be valid if there are no errors" do
      assert @model.valid?
    end
    
    should "be invalid if there are any errors" do
      @model.add_error(:foo, "foo")
      assert !@model.valid?
    end
    
    should "have a validate method by default which returns true" do
      assert @model.validate
    end
  end
  
  context "specific validations" do
    setup do
      @model = ValidatableModel.new
    end
    
    context "validates_presence_of" do
      setup do
        @model.foos = "foo"
        @model.bars = "bar"
      end
      
      should "not add an error if not blank" do
        @model.validates_presence_of(:foos)
        assert @model.valid?
      end
      
      should "add an error if blank field" do
        @model.foos = ""
        @model.validates_presence_of(:foos)
        assert !@model.valid?
      end
      
      should "add an error for a nil field" do
        @model.foos = nil
        @model.validates_presence_of(:foos)
        assert !@model.valid?
      end
      
      should "validate multiple fields" do
        @model.bars = nil
        @model.validates_presence_of([:foos, :bars])
        
        assert !@model.valid?
        assert @model.errors[:bars]
      end
      
      should "return false on invalid" do
        @model.bars =  nil
        assert !@model.validates_presence_of(:bars)
      end
      
      should "return true on valid" do
        @model.bars = "foo"
        assert @model.validates_presence_of(:bars)
      end
      
      should "return false if any are invalid on multiple fields" do
        @model.bars = nil
        assert !@model.validates_presence_of([:foos, :bars])
      end
      
      should "return true if all fields are valid" do
        @model.foos = "foo"
        @model.bars = "bar"
        assert @model.validates_presence_of([:foos, :bars])
      end
    end
  end
end