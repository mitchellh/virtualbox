require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class RelatableTest < Test::Unit::TestCase
  class Relatee
    def self.populate_relationship(caller, data)
      # Nothing?
    end
    
    def self.save_relationship(caller, data)
      # Nothing?
    end
  end
  
  class RelatableModel
    include VirtualBox::AbstractModel::Relatable
    
    relationship :foos, Relatee
  end
  
  setup do
    @data = {}
  end
  
  context "saving relationships" do
    setup do
      @model = RelatableModel.new
    end
    
    should "call save_relationship on the related class" do
      Relatee.expects(:save_relationship).with(@model, @model.foos).once
      @model.save_relationships
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