require File.join(File.dirname(__FILE__), '..', 'test_helper')

class HardDriveTest < Test::Unit::TestCase
  setup do
    VirtualBox::Command.stubs(:execute)
  end
  
  context "creating a hard drive" do
    setup do
      @location = "foo.foo"
      @size = "758"
      @format = "VDI"
      
      @hd = VirtualBox::HardDrive.new
      @hd.location = @location
      @hd.size = @size
      
      @fake_hd = mock("hd")
      @fake_hd.stubs(:attributes).returns({
        :uuid => "foo"
      })
      
      VirtualBox::HardDrive.stubs(:find).returns(@fake_hd)
      VirtualBox::Command.stubs(:vboxmanage).returns("UUID: FOO")
    end
    
    should "call create on save" do
      @hd.expects(:create).once
      
      assert @hd.new_record?
      @hd.save
    end
    
    should "call not call create on existing records" do
      @hd.save
      assert !@hd.new_record?
      
      @hd.expects(:create).never
      @hd.save
    end
    
    should "call createhd" do
      VirtualBox::Command.expects(:vboxmanage).with("createhd --filename #{@location} --size #{@size} --format #{@format} --remember")
      @hd.save
    end
    
    should "replace attributes with those of the newly created hard drive" do
      @hd.save
      
      assert_equal "foo", @hd.uuid
    end
  end
  
  context "finding a single hard drive" do
    setup do
      @raw = <<-raw
VirtualBox Command Line Management Interface Version 3.1.2
(C) 2005-2009 Sun Microsystems, Inc.
All rights reserved.

UUID:                 11dedd14-57a1-4bdb-adeb-dd1d67f066e1
Accessible:           yes
Description:          
Logical size:         20480 MBytes
Current size on disk: 1218 MBytes
Type:                 normal (base)
Storage format:       VDI
In use by VMs:        FooVM (UUID: 696249ad-00b6-4087-b47f-9b82629efc31)
Location:             /Users/mitchellh/Library/VirtualBox/HardDisks/foo.vdi
raw
      @name = "foo"
      
      VirtualBox::Command.expects(:vboxmanage).with("showhdinfo #{@name}").returns(@raw)
    end
    
    should "parse proper fields" do
      @expected = {
        :uuid => "11dedd14-57a1-4bdb-adeb-dd1d67f066e1",
        :accessible => "yes",
        :size => "20480",
        :location => "/Users/mitchellh/Library/VirtualBox/HardDisks/foo.vdi"
      }
      
      hd = VirtualBox::HardDrive.find(@name)
      assert hd.is_a?(VirtualBox::HardDrive)
      
      @expected.each do |k,v|
        assert_equal v, hd.send(k)
      end
    end
  end
  
  context "retrieving all hard drives" do
    setup do
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
      
      @hd = mock("hd")
      @hd.stubs(:is_a?).with(VirtualBox::HardDrive).returns(true)
      VirtualBox::HardDrive.expects(:find).at_least(0).returns(@hd)
    end
    
    should "return an array of HardDrive objects" do
      result = VirtualBox::HardDrive.all
      assert result.is_a?(Array)
      
      result.each { |v| assert v.is_a?(VirtualBox::HardDrive) }
    end
  end
end