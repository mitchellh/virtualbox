require File.join(File.dirname(__FILE__), '..', 'test_helper')

class AbstractModelTest < Test::Unit::TestCase
  class Foo
    def self.set_relationship(caller, old_value, new_value)
      new_value
    end

    def self.validate_relationship(caller, data)
    end
  end

  class Bar; end

  class FakeModel < VirtualBox::AbstractModel
    attribute :foo, :property => false
    attribute :bar
    relationship :foos, Foo
    relationship :bars, Bar, :dependent => :destroy
  end

  context "reloading" do
    context "with a single class" do
      setup do
        @model = FakeModel.new
      end

      teardown do
        FakeModel.reloaded!
      end

      should "not want to be reloaded initially" do
        assert !FakeModel.reload?
      end

      should "want to be reloaded once signaled by the class method" do
        FakeModel.reload!
        assert FakeModel.reload?
      end

      should "want to be reloaded once signaled by the instance method" do
        @model.reload!
        assert FakeModel.reload?
      end

      should "not want to be reloaded once reloaded! is called" do
        @model.reload!
        assert FakeModel.reload?
        FakeModel.reloaded!
        assert !FakeModel.reload?
      end
    end

    context "with inheritance" do
      class SubModel < FakeModel
      end

      setup do
        @lazy = FakeModel.new
        @sub = SubModel.new
      end

      should "not interfere with each others reload flags" do
        @lazy.reload!
        assert !SubModel.reload?
        assert FakeModel.reload?
      end
    end
  end

  context "lazy attributes and relationships" do
    class LazyModel < VirtualBox::AbstractModel
      attribute :foo, :lazy => true
      attribute :bar
      relationship :foos, AbstractModelTest::Foo, :lazy => true
      relationship :bars, AbstractModelTest::Bar, :lazy => true
    end

    setup do
      @model = LazyModel.new
    end

    should "return false on lazy_attribute? for all attributes if new" do
      assert !@model.lazy_attribute?(:foo)
      assert !@model.lazy_relationship?(:foos)
    end

    should "only save loaded relationships" do
      @model.existing_record!
      assert @model.lazy_relationship?(:foos)
      assert @model.lazy_relationship?(:bars)
      @model.stubs(:loaded_relationship?).with(:foos).returns(false)
      @model.stubs(:loaded_relationship?).with(:bars).returns(true)
      @model.expects(:save_relationship).with(:bars).once
      @model.save
    end
  end

  context "inspecting" do
    setup do
      @model = FakeModel.new
    end

    should "generate the proper inspect string" do
      assert_equal "#<AbstractModelTest::FakeModel :bar=nil, :bars=..., :foo=nil, :foos=...>", @model.inspect
    end

    should "turn attributes which are AbstractModels into classes" do
      @model.foo = @model.dup
      assert_equal "#<AbstractModelTest::FakeModel :bar=nil, :bars=..., :foo=#<AbstractModelTest::FakeModel>, :foos=...>", @model.inspect
    end

    should "turn attributes which are AbstractInterfaces into classes" do
      @model.foo = VirtualBox::COM::Util.versioned_interface(:VirtualBox).new(VirtualBox::COM::Implementer::Nil, nil)
      assert_equal "#<AbstractModelTest::FakeModel :bar=nil, :bars=..., :foo=#<VirtualBox::COM::Interface::Version_3_2_X::VirtualBox>, :foos=...>", @model.inspect
    end
  end

  context "validation" do
    setup do
      @model = FakeModel.new
    end

    should "clear all previous errors" do
      @model.expects(:clear_errors).once
      @model.validate
    end

    should "call validate_relationship on each relationship class" do
      Foo.expects(:validate_relationship).once.with(@model, nil)
      @model.validate
    end

    should "forward arguments to validate_relationship" do
      Foo.expects(:validate_relationship).once.with(@model, nil, "HELLO")
      @model.validate("HELLO")
    end

    should "succeed if all relationships succeeded" do
      Foo.expects(:validate_relationship).returns(true)
      assert @model.validate
    end

    should "fail if one relationship failed to validate" do
      Foo.expects(:validate_relationship).returns(true)
      Bar.expects(:validate_relationship).returns(false)
      assert !@model.validate
    end

    context "errors" do
      should "return the errors of the relationships, as well as the model itself" do
        @model.foo = nil
        assert !@model.validate

        @model.validates_presence_of(:foo)
        Foo.expects(:errors_for_relationship).with(@model, nil).returns("BAD")
        errors = @model.errors
        assert errors.has_key?(:foos)
        assert_equal "BAD", errors[:foos]
        assert errors.has_key?(:foo)
      end
    end
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

    should "become a new record again if new_record! is called" do
      assert @model.new_record?
      @model.save
      assert !@model.new_record?
      @model.new_record!
      assert @model.new_record?
    end

    should "become an existing record if existing_record! is called" do
      assert @model.new_record?
      @model.existing_record!
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

    context "populating attributes" do
      should "populate relationships at the same time as attributes" do
        Foo.expects(:populate_relationship).once
        @model.populate_attributes({})
      end

      should "not populate relationships if :ignore_relationships is true" do
        Foo.expects(:populate_relationship).never
        @model.populate_attributes({}, :ignore_relationships => true)
      end

      should "cause the model to become an existing record" do
        assert @model.new_record?
        @model.populate_attributes({})
        assert !@model.new_record?
      end

      should "not cause dirtiness" do
        assert_nil @model.foo
        @model.populate_attributes({ :foo => "foo" })
        assert_equal "foo", @model.foo
        assert !@model.changed?
      end
    end

    context "populating relationships" do
      should "cause the model to become an existing record" do
        assert @model.new_record?
        @model.populate_relationships({})
        assert !@model.new_record?
      end

      should "not cause dirtiness" do
        # TODO: This test doesn't do much right now. We need to actually compare
        # the relationship values for dirtiness.
        @model.populate_relationships({ :foo => "foo" })
        assert !@model.changed?
      end
    end

    context "populating a single relationship" do
      should "cause the model to become an existing record" do
        assert @model.new_record?
        @model.populate_relationship(:foos, {})
        assert !@model.new_record?
      end

      should "not cause dirtiness" do
        @model.populate_relationship(:foos, {})
        assert !@model.changed?
      end
    end
  end

  context "integrating interface attributes" do
    setup do
      @model = FakeModel.new
    end

    should "clear the dirty state of an attribute after saving" do
      key = :foo
      interface = :bar
      @model.expects(:clear_dirty!).with(key).once
      @model.save_interface_attribute(key, interface)
    end
  end

  context "integrating relatable" do
    setup do
      @model = FakeModel.new
    end

    context "saving all changed interface attributes" do
      setup do
        @changes = [[:a, []], [:b, []], [:c, []]]
        @model.stubs(:changes).returns(@changes)
      end

      should "save each" do
        @model.changes.each do |key, options|
          @model.expects(:save_interface_attribute).with(key, @interface)
        end

        @model.save_changed_interface_attributes(@interface)
      end
    end

    context "with dirty" do
      should "set dirty state when a relationship is set" do
        assert !@model.changed?
        @model.foos = "foo"
        assert @model.changed?
      end
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

    should "not mark dirtiness on write_attribute if the attribute is lazy and not yet loaded" do
      @model.expects(:lazy_attribute?).with(:foo).returns(true)
      @model.expects(:loaded_attribute?).with(:foo).returns(false)
      @model.expects(:set_dirty!).never
      @model.write_attribute(:foo, "foo2")
    end
  end
end
