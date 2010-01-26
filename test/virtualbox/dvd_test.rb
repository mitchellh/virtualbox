require File.join(File.dirname(__FILE__), '..', 'test_helper')

class DVDTest < Test::Unit::TestCase
  setup do
    VirtualBox::Command.stubs(:execute)
  end
  
  context "destroying a dvd" do
    setup do
      @dvd = VirtualBox::DVD.new
    end
    
    should "return false if attempting to destroy an empty drive" do
      assert !VirtualBox::DVD.empty_drive.destroy
    end
    
    should "call vboxmanage to destroy it" do
      VirtualBox::Command.expects(:vboxmanage).with("closemedium dvd #{@dvd.uuid} --delete")
      assert @dvd.destroy
    end
    
    should "return false if destroy failed" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert !@dvd.destroy
    end
    
    should "raise an exception if failed and flag is set" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @dvd.destroy(true)
      }
    end
  end
  
  context "empty drive" do
    should "return an empty drive instance by calling new with :empty_drive" do
      dvd = VirtualBox::DVD.new(:empty_drive)
      assert dvd.empty_drive?
    end
    
    should "call new with :empty_drive with empty_drive class method" do
      dvd = VirtualBox::DVD.empty_drive
      assert dvd.empty_drive?
    end
  end
  
  context "retrieving all dvds" do
    setup do
      @expectations = {
        "d3252617-8176-4f8c-9d73-1c9c82b23960" => {
          :location   => "/Users/mitchellh/Downloads/jeos-8.04.3-jeos-i386.iso",
          :accessible => "yes"
        },
        
        "4a08f52c-bca3-4908-8da4-4f48aaa4ebba" => {
          :location   => "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso",
          :accessible => "yes"
        }
      }
      
      @valid = <<-valid
VirtualBox Command Line Management Interface Version 3.1.2
(C) 2005-2009 Sun Microsystems, Inc.
All rights reserved.

UUID:       d3252617-8176-4f8c-9d73-1c9c82b23960
Path:       /Users/mitchellh/Downloads/jeos-8.04.3-jeos-i386.iso
Accessible: yes

UUID:       4a08f52c-bca3-4908-8da4-4f48aaa4ebba
Path:       /Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso
Accessible: yes
Usage:      TestJeOS (UUID: 3d0f87b4-50f7-4fc5-ad89-93375b1b32a3)
valid

      VirtualBox::Command.expects(:vboxmanage).with("list dvds").returns(@valid)
    end
    
    should "return an array of DVD objects" do
      result = VirtualBox::DVD.all
      assert result.is_a?(Array)
      
      result.each { |v| assert v.is_a?(VirtualBox::DVD) }
    end
    
    should "return the proper results" do
      result = VirtualBox::DVD.all
      assert result.is_a?(Array)
      assert_equal @expectations.length, result.length
      
      result.each do |image|
        expected_image = @expectations[image.uuid]
        assert expected_image
        
        expected_image.each do |k,v|
          assert_equal v, image.read_attribute(k)
        end
      end
    end
  end
end