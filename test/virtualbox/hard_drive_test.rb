require File.join(File.dirname(__FILE__), '..', 'test_helper')

class HardDriveTest < Test::Unit::TestCase
  context "retrieving all hard drives" do
    setup do
      @expectations = {
        "9d2e4353-d1e9-466c-ac58-f2249264147b" => {
          :format     => "VDI",
          :location   => "/Users/mitchellh/Library/VirtualBox/HardDisks/foo.vdi",
          :accessible => "yes"
        },
        
        "11dedd14-57a1-4bdb-adeb-dd1d67f066e1" => {
          :format     => "VDI",
          :location   => "/Users/mitchellh/Library/VirtualBox/HardDisks/bar.vdi",
          :accessible => "yes"
        },
        
        "5e090af6-7d71-4f40-8b03-33aa665f9ecf" => {
          :format     => "VMDK",
          :location   => "/Users/mitchellh/Library/VirtualBox/HardDisks/baz.vmdk",
          :accessible => "yes"
        }
      }
      
      @valid = <<-valid
VirtualBox Command Line Management Interface Version 3.1.2
(C) 2005-2009 Sun Microsystems, Inc.
All rights reserved.
      
UUID:       9d2e4353-d1e9-466c-ac58-f2249264147b
Format:     VDI
Location:   /Users/mitchellh/Library/VirtualBox/HardDisks/foo.vdi
Accessible: yes
Type:       normal
Usage:      TestJeOS (UUID: 3d0f87b4-50f7-4fc5-ad89-93375b1b32a3)

UUID:       11dedd14-57a1-4bdb-adeb-dd1d67f066e1
Format:     VDI
Location:   /Users/mitchellh/Library/VirtualBox/HardDisks/bar.vdi
Accessible: yes
Type:       normal
Usage:      HoboBase (UUID: 696249ad-00b6-4087-b47f-9b82629efc31)

UUID:       5e090af6-7d71-4f40-8b03-33aa665f9ecf
Format:     VMDK
Location:   /Users/mitchellh/Library/VirtualBox/HardDisks/baz.vmdk
Accessible: yes
Type:       normal
Usage:      foo (UUID: 8710d3db-d96a-46ed-9004-59fa891fda90)
valid

      VirtualBox::Command.expects(:vboxmanage).with("list hdds").returns(@valid)
    end
    
    should "return an array of HardDrive objects" do
      result = VirtualBox::HardDrive.all
      assert result.is_a?(Array)
      
      result.each { |v| assert v.is_a?(VirtualBox::HardDrive) }
    end
    
    should "return the proper results" do
      result = VirtualBox::HardDrive.all
      assert result.is_a?(Array)
      assert_equal @expectations.length, result.length
      
      result.each do |hd|
        expected_hd = @expectations[hd.uuid]
        assert expected_hd
        
        expected_hd.each do |k,v|
          assert_equal v, hd.read_attribute(k)
        end
      end
    end
  end
  
  context "parsing a single block" do
    should "return nil for an invalid block" do
      assert VirtualBox::HardDrive.create_from_block("HI").nil?
    end
    
    should "return nil if not all required fields are present" do
      block = <<-block
UUID: yes
FOO: wrong
block
      assert VirtualBox::HardDrive.create_from_block(block).nil?        
    end
      
    should "properly parse if all properties are available" do
      expected = {
        :uuid => "1234567890",
        :format => "vdi",
        :location => "foo",
        :accessible => "yes"
      }
        
      block = ""
      expected.each { |k,v| block += "#{k}: #{v}\n" }

      result = VirtualBox::HardDrive.create_from_block(block)
      assert !result.nil?
      
      expected.each do |k,v|
        assert_equal v, result.read_attribute(k)
      end
    end
  end
end