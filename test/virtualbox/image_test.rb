require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ImageTest < Test::Unit::TestCase
  context "image type and empty drive" do
    setup do
      @image = VirtualBox::Image.new
    end
    
    should "raise an exception if image_type is called on Image" do
      assert_raises(RuntimeError) { @image.image_type }
    end
    
    should "return false by default on empty_drive?" do
      assert !@image.empty_drive?
    end
  end
  
  context "in a relationship" do
    class ImageRelationshipModel < VirtualBox::AbstractModel
      relationship :image, VirtualBox::Image
    end
    
    setup do
      @model = ImageRelationshipModel.new
    end
    
    context "populating a relationship" do
      should "return 'emptydrive' if the medium is an empty drive" do
        result = VirtualBox::Image.populate_relationship(@model, {
          :medium => "emptydrive"
        })
        
        assert result.is_a?(VirtualBox::DVD)
        assert result.empty_drive?
      end
      
      should "return nil if uuid is nil and medium isn't empty" do
        result = VirtualBox::Image.populate_relationship(@model, {})
        assert result.nil?
      end
      
      should "result a matching image from subclasses if uuid" do
        uuid = "foo'"

        subobject = mock("subobject")
        subobject.stubs(:uuid).returns(uuid)
        
        subclass = mock("subclass")
        subclass.stubs(:all).returns([subobject])
        
        VirtualBox::Image.expects(:subclasses).returns([subclass])
        
        result = VirtualBox::Image.populate_relationship(@model, { :uuid => uuid })
        assert_equal subobject, result
      end
      
      should "result in nil if suboject can't be found" do
        VirtualBox::Image.expects(:subclasses).returns([])
        assert_nil VirtualBox::Image.populate_relationship(@model, { :uuid => "foo" })
      end
    end
    
    context "setting relationship object" do
      should "raise an InvalidRelationshipObjectException if new value is not an image" do
        assert_raises(VirtualBox::Exceptions::InvalidRelationshipObjectException) {
          @model.image = "foo"
        }
      end

      should "not raise an exception if setting to nil" do
        assert_nothing_raised { @model.image = nil }
      end

      should "just return the new value if it is an image" do
        image = VirtualBox::Image.new
        assert_nil @model.image
        assert_nothing_raised { @model.image = image }
        assert_equal image, @model.image
      end
    end
  end
  
  context "recording subclasses" do
    should "list all subclasses" do
      assert_nothing_raised { VirtualBox::Image.subclasses }
    end
  end
  
  context "parsing raw" do
    setup do
      @raw = <<-raw
VirtualBox Command Line Management Interface Version 3.1.2
(C) 2005-2009 Sun Microsystems, Inc.
All rights reserved.

UUID:       9d2e4353-d1e9-466c-ac58-f2249264147b
Format:     VDI
Location:   /Users/mitchellh/Library/VirtualBox/HardDisks/TestJeOS.vdi
Accessible: yes
Type:       normal
Usage:      TestJeOS (UUID: 3d0f87b4-50f7-4fc5-ad89-93375b1b32a3)

UUID:       11dedd14-57a1-4bdb-adeb-dd1d67f066e1
Format:     VDI
Location:   /Users/mitchellh/Library/VirtualBox/HardDisks/HoboBase.vdi
Accessible: yes
Type:       normal
Usage:      HoboBase (UUID: 696249ad-00b6-4087-b47f-9b82629efc31)

UUID:       322f79fd-7da6-416f-a16f-e70066ccf165
Format:     VMDK
Location:   /Users/mitchellh/Library/VirtualBox/HardDisks/HoboBase.vmdk
Accessible: yes
Type:       normal
Usage:      HoboBase_2 (UUID: 3cc36c5d-562a-4030-8acf-f061f44170c4)      
raw
    end
    
    should "call parse block the correct number of times" do
      VirtualBox::Image.expects(:parse_block).times(4).returns({})
      VirtualBox::Image.parse_raw(@raw)
    end
    
    should "remove nil (invalid) blocks from result" do
      result = VirtualBox::Image.parse_raw(@raw)
      assert_equal 3, result.length
    end
  end
  
  context "parsing multiple blocks" do
    setup do
      @raw = <<-raw
one

two

three
raw
    end
    
    should "call parse block for each multiline" do
      parse_seq = sequence("parse")
      VirtualBox::Image.expects(:parse_block).with("one").in_sequence(parse_seq)
      VirtualBox::Image.expects(:parse_block).with("two").in_sequence(parse_seq)
      VirtualBox::Image.expects(:parse_block).with("three").in_sequence(parse_seq)
      VirtualBox::Image.parse_blocks(@raw)
    end
    
    should "return an array of the parses with nil ignored" do
      parse_seq = sequence("parse")
      VirtualBox::Image.expects(:parse_block).with("one").returns({}).in_sequence(parse_seq)
      VirtualBox::Image.expects(:parse_block).with("two").returns(nil).in_sequence(parse_seq)
      VirtualBox::Image.expects(:parse_block).with("three").returns({}).in_sequence(parse_seq)
      result = VirtualBox::Image.parse_blocks(@raw)
      
      assert result.is_a?(Array)
      assert_equal 2, result.length
    end
  end
  
  context "parsing a single block" do
    setup do
      @expected = {
        :uuid => "1234567890",
        :path => "foo",
        :accessible => "yes"
      }
        
      @block = ""
      @expected.each { |k,v| @block += "#{k}: #{v}\n" }
    end
    
    should "return nil for an invalid block" do
      assert VirtualBox::Image.parse_block("HI").nil?
    end
    
    should "mirror location to path" do
      result = VirtualBox::Image.parse_block(@block)
      assert_equal "foo", result[:location]
    end
      
    should "properly parse if all properties are available" do
      result = VirtualBox::Image.parse_block(@block)
      assert !result.nil?
      
      @expected.each do |k,v|
        k = :location if k == :path
        assert_equal v, result[k]
      end
    end
  end
end