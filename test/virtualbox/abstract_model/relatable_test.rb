require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class RelatableTest < Test::Unit::TestCase
  class Relatee
    def self.populate_relationship(caller, data)
      "FOO"
    end
  end
  class BarRelatee; end
  
  class RelatableModel
    include VirtualBox::AbstractModel::Relatable
    
    relationship :foos, Relatee
    relationship :bars, BarRelatee
  end
  
  setup do
    @data = {}
  end
  
  context "subclasses" do
    class SubRelatableModel < RelatableModel
      relationship :bars, Relatee
    end
    
    setup do
      @relationships = SubRelatableModel.relationships
    end
    
    should "inherit relationships of parent" do
      assert @relationships.has_key?(:foos)
      assert @relationships.has_key?(:bars)
    end
    
    should "inherit options of relationships" do
      assert_equal Relatee, @relationships[:foos][:klass]
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
  
  context "saving relationships" do
    setup do
      @model = RelatableModel.new
    end
    
    should "call save_relationship on the related class" do
      Relatee.expects(:save_relationship).with(@model, @model.foos).once
      @model.save_relationships
    end
    
    should "forward parameters through" do
      Relatee.expects(:save_relationship).with(@model, @model.foos, "YES").once
      @model.save_relationships("YES")
    end
  end
  
  context "reading relationships" do
    setup do
      @model = RelatableModel.new
    end
    
    should "provide a read method for relationships" do
      assert_nothing_raised { @model.foos }
    end
  end
  
  context "populating relationships" do
    setup do
      @model = RelatableModel.new
    end
    
    should "call populate_relationship on the related class" do
      Relatee.expects(:populate_relationship).with(@model, @data).once
      @model.populate_relationships(@data)
    end
    
    should "properly save returned value as the value for the relationship" do
      Relatee.expects(:populate_relationship).once.returns("HEY")
      @model.populate_relationships(@data)
      assert_equal "HEY", @model.foos
    end
  end
end