require File.expand_path("../../../test_helper", __FILE__)

class RelatableTest < Test::Unit::TestCase
  class Relatee
    def self.populate_relationship(caller, data)
      "FOO"
    end
  end

  class BarRelatee
    def self.set_relationship(caller, old_value, new_value)
    end
  end

  class EmptyRelatableModel
    include VirtualBox::AbstractModel::Relatable
  end

  class RelatableModel < EmptyRelatableModel
    relationship :foos, RelatableTest::Relatee
    relationship :bars, RelatableTest::BarRelatee
  end

  setup do
    @data = {}
  end

  context "class methods" do
    should "read back relationships in order added" do
      order = mock("order")
      order_seq = sequence("order_seq")
      order.expects(:foos).in_sequence(order_seq)
      order.expects(:bars).in_sequence(order_seq)

      RelatableModel.relationships.each do |name, options|
        order.send(name)
      end
    end
  end

  context "setting a relationship" do
    setup do
      @model = RelatableModel.new
    end

    should "have a magic method relationship= which calls set_relationship" do
      @model.expects(:set_relationship).with(:foos, "FOOS!")
      @model.foos = "FOOS!"
    end

    should "raise a NonSettableRelationshipException if relationship can't be set" do
      assert_raises(VirtualBox::Exceptions::NonSettableRelationshipException) {
        @model.foos = "FOOS!"
      }
    end

    should "call set_relationship on the relationship class" do
      BarRelatee.expects(:populate_relationship).returns("foo")
      @model.populate_relationships({})

      BarRelatee.expects(:set_relationship).with(@model, "foo", "bars")
      assert_nothing_raised { @model.bars = "bars" }
    end

    should "set the result of set_relationship as the new relationship data" do
      BarRelatee.stubs(:set_relationship).returns("hello")
      @model.bars = "zoo"
      assert_equal "hello", @model.bars
    end
  end

  context "subclasses" do
    class SubRelatableModel < RelatableModel
      relationship :bars, RelatableTest::Relatee
    end

    setup do
      @relationships = SubRelatableModel.relationships
    end

    should "inherit relationships of parent" do
      assert SubRelatableModel.has_relationship?(:foos)
      assert SubRelatableModel.has_relationship?(:bars)
    end

    should "inherit options of relationships" do
      assert_equal Relatee, SubRelatableModel.relationships_hash[:foos][:klass]
    end
  end

  context "default callbacks" do
    setup do
      @model = RelatableModel.new
    end

    should "not raise an error if populate_relationship doesn't exist" do
      assert !BarRelatee.respond_to?(:populate_relationship)
      assert_nothing_raised { @model.populate_relationships(nil) }
    end

    should "not raise an error when saving relationships if the callback doesn't exist" do
      assert !Relatee.respond_to?(:save_relationship)
      assert_nothing_raised { @model.save_relationships }
    end

    should "not raise an error in destroying relationships if the callback doesn't exist" do
      assert !Relatee.respond_to?(:destroy_relationship)
      assert_nothing_raised { @model.destroy_relationships }
    end
  end

  context "destroying" do
    setup do
      @model = RelatableModel.new
      @model.populate_relationships({})
    end

    context "a single relationship" do
      should "call destroy_relationship only for the given relationship" do
        Relatee.expects(:destroy_relationship).once
        BarRelatee.expects(:destroy_relationship).never
        @model.destroy_relationship(:foos)
      end

      should "forward any args passed into destroy_relationship" do
        Relatee.expects(:destroy_relationship).with(@model, anything, "HELLO").once
        @model.destroy_relationship(:foos, "HELLO")
      end

      should "pass the data into destroy_relationship" do
        Relatee.expects(:destroy_relationship).with(@model, "FOO").once
        @model.destroy_relationship(:foos)
      end

      should "call read_relationship (to force the load if lazy)" do
        Relatee.expects(:destroy_relationship).with(@model, "FOO").once
        @model.expects(:read_relationship).with(:foos).once
        @model.destroy_relationship(:foos)
      end
    end

    context "all relationships" do
      should "call destroy_relationship on the related class" do
        Relatee.expects(:destroy_relationship).with(@model, anything).once
        @model.destroy_relationships
      end

      should "forward any args passed into destroy relationships" do
        Relatee.expects(:destroy_relationship).with(@model, anything, "HELLO").once
        @model.destroy_relationships("HELLO")
      end
    end
  end

  context "lazy relationships" do
    class LazyRelatableModel < EmptyRelatableModel
      relationship :foos, RelatableTest::Relatee, :lazy => true
      relationship :bars, RelatableTest::BarRelatee
    end

    setup do
      @model = LazyRelatableModel.new
    end

    should "return true if a relationship is lazy, and false if not, when checking" do
      assert @model.lazy_relationship?(:foos)
      assert !@model.lazy_relationship?(:bars)
    end

    should "not be loaded by default" do
      assert !@model.loaded_relationship?(:foos)
    end

    should "call `load_relationship` on initial load" do
      @model.expects(:load_relationship).with(:foos).once
      @model.foos
    end

    should "not call `load_relationship` for non lazy attributes" do
      @model.expects(:load_relationship).never
      @model.bars
    end

    should "mark a relationship as loaded on populate_relationship" do
      @model.populate_relationship(:foos, {})
      assert @model.loaded_relationship?(:foos)
    end

    should "not populate the lazy relationship right away" do
      Relatee.expects(:populate_relationship).never
      BarRelatee.expects(:populate_relationship).once
      @model.populate_relationships({})
    end
  end

  context "saving relationships" do
    class RelatableWithLazyModel < RelatableModel
      relationship :bazs, RelatableTest::Relatee, :lazy => true
      relationship :vers, RelatableTest::Relatee, :version => "3.1"

      def load_relationship(name)
        populate_relationship(:bazs, "foo")
      end
    end

    setup do
      @model = RelatableWithLazyModel.new
      VirtualBox.stubs(:version).returns("3.1.3")
    end

    should "call save_relationship for all relationships" do
      @model.expects(:save_relationship).with(:foos).returns(true)
      @model.expects(:save_relationship).with(:bars).returns(true)
      @model.expects(:save_relationship).with(:bazs).returns(true)
      @model.expects(:save_relationship).with(:vers).returns(true)
      assert @model.save_relationships
    end

    should "not call save_relationship on non-loaded relations" do
      Relatee.expects(:save_relationship).never
      @model.save_relationship(:bazs)
    end

    should "not call save_relationship on relationships with mismatched versions" do
      VirtualBox.stubs(:version).returns("3.2.4")
      Relatee.expects(:save_relationship).never
      @model.save_relationship(:vers)
    end

    should "call save_relationship on loaded lazy relationships" do
      @model.load_relationship(:bazs)
      Relatee.expects(:save_relationship).once
      @model.save_relationship(:bazs)
    end

    should "call save_relationship on the related class" do
      Relatee.expects(:save_relationship).with(@model, @model.foos).once.returns(:r)
      assert_equal :r, @model.save_relationship(:foos)
    end

    should "forward parameters through" do
      Relatee.expects(:save_relationship).with(@model, @model.foos, "YES").once
      @model.save_relationship(:foos, "YES")
    end
  end

  context "reading relationships" do
    class VersionedRelatableModel < RelatableModel
      relationship :ver, :Ver, :version => "3.1"
    end

    setup do
      @model = VersionedRelatableModel.new
    end

    should "provide a read method for relationships" do
      assert_nothing_raised { @model.foos }
    end

    should "raise an exception if invalid version for versioned relationships" do
      VirtualBox.stubs(:version).returns("3.0.14")
      assert_raises(VirtualBox::Exceptions::UnsupportedVersionException) {
        @model.ver
      }
    end

    should "not raise an exception if valid version for versioned relationship" do
      VirtualBox.stubs(:version).returns("3.1.8")
      assert_nothing_raised {
        @model.ver
      }
    end
  end

  context "checking for relationships" do
    setup do
      @model = RelatableModel.new
    end

    should "have a class method as well" do
      assert RelatableModel.has_relationship?(:foos)
      assert !RelatableModel.has_relationship?(:bazs)
    end

    should "return true for existing relationships" do
      assert @model.has_relationship?(:foos)
    end

    should "return false for nonexistent relationships" do
      assert !@model.has_relationship?(:bazs)
    end
  end

  context "determining the class of relationships" do
    class ClassRelatableModel < EmptyRelatableModel
      relationship :foo, RelatableTest::Relatee
      relationship :bar, "RelatableTest::BarRelatee"
    end

    setup do
      @model = ClassRelatableModel.new
    end

    should "just return the class for Class types" do
      assert_equal Relatee, @model.relationship_class(:foo)
    end

    should "turn string into class" do
      assert_equal BarRelatee, @model.relationship_class(:bar)
    end
  end

  context "populating relationships" do
    class PopulatingRelatableModel < RelatableModel
      relationship :bazs, RelatableTest::Relatee, :version => "3.1"
    end

    setup do
      @model = PopulatingRelatableModel.new
      VirtualBox.stubs(:version).returns("3.1.4")
    end

    should "be able to populate a single relationship" do
      Relatee.expects(:populate_relationship).with(@model, @data).once
      @model.populate_relationship(:foos, @data)
    end

    should "not populate versioned relationships if version mismatch" do
      VirtualBox.stubs(:version).returns("3.0.4")
      Relatee.expects(:populate_relationship).never
      @model.populate_relationship(:bazs, @data)
    end

    should "call populate_relationship on the related class" do
      populate_seq = sequence("populate_seq")
      @model.expects(:populate_relationship).with(:foos, @data).once.in_sequence(populate_seq)
      @model.expects(:populate_relationship).with(:bars, @data).once.in_sequence(populate_seq)
      @model.expects(:populate_relationship).with(:bazs, @data).once.in_sequence(populate_seq)
      @model.populate_relationships(@data)
    end

    should "properly save returned value as the value for the relationship" do
      Relatee.expects(:populate_relationship).twice.returns("HEY")
      @model.populate_relationships(@data)
      assert_equal "HEY", @model.foos
    end
  end
end
