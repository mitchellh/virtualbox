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

    should "be able to get full error messages" do
      @model.add_error(:foo, "should be bar.")
      assert_equal ['Foo should be bar.'], @model.full_error_messages
    end

    should "be able to get the errors on a specific field" do
      @model.add_error(:foo, "an error.")
      assert @model.errors_on(:bar).nil?
      assert @model.errors_on(:foo)
    end
  end

  context "validity" do
    setup do
      @model = ValidatableModel.new
    end

    should "call validate on valid?" do
      @model.expects(:validate)
      assert @model.valid?
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
        @model.validates_presence_of(:foos, :bars)

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
        assert !@model.validates_presence_of(:foos, :bars)
      end

      should "return true if all fields are valid" do
        @model.foos = "foo"
        @model.bars = "bar"
        assert @model.validates_presence_of(:foos, :bars)
      end

      should "add error message if invalid" do
        @model.foos = nil
        assert !@model.validates_presence_of(:foos)
        assert_equal "can't be blank.", @model.errors[:foos].first
      end

      should "use custom error message if given" do
        @model.foos = nil
        assert !@model.validates_presence_of(:foos, :message => "can't be nil.")
        assert_equal "can't be nil.", @model.errors[:foos].first
      end
    end

    context "validates_format_of" do
      setup do
        @model.foos = "foo"
        @model.bars = "bar"
      end

      should "not add an error if formatted properly" do
        @model.validates_format_of(:foos, :with => /^foo$/)
        assert @model.valid?
      end

      should "add an error if not formatted properly" do
        @model.validates_format_of(:bars, :with => /^foo$/)
        assert !@model.valid?
      end

      should "not add an error for a nil field" do
        @model.foos = nil
        @model.validates_format_of(:foos, :with => /^foo$/)
        assert @model.valid?
      end

      should "validate multiple fields" do
        @model.validates_format_of(:foos, :bars, :with => /^foo$/)
        assert !@model.valid?
        assert @model.errors[:bars]
      end

      should "return false on invalid" do
        assert !@model.validates_format_of(:bars, :with => /^foo$/)
      end

      should "return true on valid" do
        assert @model.validates_format_of(:foos, :with => /^foo$/)
      end

      should "return false if any are invalid on multiple fields" do
        assert !@model.validates_format_of(:foos, :bars, :with => /^foo$/)
      end

      should "return true if all fields are valid" do
        assert @model.validates_format_of(:foos, :bars, :with => /^\w+$/)
      end
    end

    context "validates_numericality_of" do
      setup do
        @model.foos = 1
        @model.bars = "1"
      end

      should "not add an error if a number" do
        @model.validates_numericality_of(:foos)
        assert @model.valid?
      end

      should "add an error if not a number" do
        @model.validates_numericality_of(:bars)
        assert !@model.valid?
      end

      should "not add an error for a nil field" do
        @model.foos = nil
        @model.validates_numericality_of(:foos)
        assert @model.valid?
      end

      should "validate multiple fields" do
        @model.validates_numericality_of(:foos, :bars)
        assert !@model.valid?
        assert @model.errors[:bars]
      end

      should "return false on invalid" do
        assert !@model.validates_numericality_of(:bars)
      end

      should "return true on valid" do
        assert @model.validates_numericality_of(:foos)
      end

      should "return false if any are invalid on multiple fields" do
        assert !@model.validates_numericality_of(:foos, :bars)
      end

      should "return true if all fields are valid" do
        @model.bars = 2
        assert @model.validates_numericality_of(:foos, :bars)
      end
    end

    context "validates_inclusion_of" do
      setup do
        @model.foos = 1
        @model.bars = 2
      end

      should "not add an error if value is included" do
        @model.validates_inclusion_of(:foos, :in => [1])
        assert @model.valid?
      end

      should "add an error if value is not included" do
        @model.validates_inclusion_of(:bars, :in => [1])
        assert !@model.valid?
      end

      should "not add an error for a nil field" do
        @model.foos = nil
        @model.validates_inclusion_of(:foos, :in => [1,2])
        assert @model.valid?
      end

      should "validate multiple fields" do
        @model.validates_inclusion_of(:foos, :bars, :in => [1,3])
        assert !@model.valid?
        assert @model.errors[:bars]
      end

      should "return false on invalid" do
        assert !@model.validates_inclusion_of(:bars, :in => [1])
      end

      should "return true on valid" do
        assert @model.validates_inclusion_of(:foos, :in => [1])
      end

      should "return false if any are invalid on multiple fields" do
        assert !@model.validates_inclusion_of(:foos, :bars, :in => [1,3])
      end

      should "return true if all fields are valid" do
        assert @model.validates_inclusion_of(:foos, :bars, :in => [1,2])
      end
    end
  end
end