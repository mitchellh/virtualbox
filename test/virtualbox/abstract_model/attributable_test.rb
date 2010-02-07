require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class AttributableTest < Test::Unit::TestCase
  class EmptyAttributeModel
    include VirtualBox::AbstractModel::Attributable
  end

  class AttributeModel < EmptyAttributeModel
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

  context "subclasses" do
    class SubModel < AttributeModel
      attribute :baz
    end

    should "have foo bar and baz" do
      attributes = SubModel.attributes
      assert attributes.has_key?(:foo)
      assert attributes.has_key?(:bar)
      assert attributes.has_key?(:baz)
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

    context "default values" do
      class DefaultModel < EmptyAttributeModel
        attribute :foo, :default => "FOO!"
        attribute :bar
      end

      setup do
        @model = DefaultModel.new
      end

      should "read default values" do
        assert_equal "FOO!", @model.foo
        assert_nil @model.bar
      end
    end

    context "lazy loading" do
      class LazyModel < EmptyAttributeModel
        attribute :foo, :lazy => true
        attribute :bar

        def load_attribute(attribute)
          write_attribute(attribute, "foo")
        end
      end

      setup do
        @model = LazyModel.new
      end

      should "return proper value for lazy_attribute?" do
        assert @model.lazy_attribute?(:foo)
        assert !@model.lazy_attribute?(:bar)
        assert !@model.lazy_attribute?(:i_dont_exist)
      end

      should "load the lazy attribute on read" do
        assert !@model.loaded_lazy_attribute?(:foo)
        assert_equal "foo", @model.foo
        assert @model.loaded_lazy_attribute?(:foo)
      end

      should "not be loaded initially, then should be loaded after being read" do
        assert !@model.loaded_lazy_attribute?(:foo)
        @model.foo
        assert @model.loaded_lazy_attribute?(:foo)
      end

      should "mark as loaded with loaded_lazy_attribute!" do
        assert !@model.loaded_lazy_attribute?(:foo)
        @model.loaded_lazy_attribute!(:foo)
        assert @model.loaded_lazy_attribute?(:foo)
      end

      should "mark as loaded if write_attribute is called on an attribute" do
        assert !@model.loaded_lazy_attribute?(:foo)
        @model.write_attribute(:foo, "bar")
        assert @model.loaded_lazy_attribute?(:foo)
        assert_equal "bar", @model.foo
      end

      should "unmark the loaded status if clear_lazy_attribute! is called" do
        @model.loaded_lazy_attribute!(:foo)
        assert @model.loaded_lazy_attribute?(:foo)
        @model.clear_lazy_attribute!(:foo)
        assert !@model.loaded_lazy_attribute?(:foo)
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

    should "be able to read an entire hash of attributes" do
      atts = @model.attributes
      assert atts.is_a?(Hash)
      assert atts.has_key?(:foo)
      assert atts.has_key?(:bar)
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