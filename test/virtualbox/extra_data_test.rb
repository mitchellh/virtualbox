require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ExtraDataTest < Test::Unit::TestCase
  setup do
    @raw = <<-raw
.
Key: GUI/LastVMSelected, Value: 02573b8e-f628-43ed-b688-e488414e07ac
Key: GUI/LastWindowPostion, Value: 99,457,770,550
Key: GUI/SUNOnlineData, Value: triesLeft=0
Key: GUI/SuppressMessages, Value: ,confirmInputCapture,remindAboutAutoCapture,confirmRemoveMedium,remindAboutInaccessibleMedia,confirmGoingFullscreen,remindAboutMouseIntegrationOn
Key: GUI/UpdateCheckCount, Value: 13
Key: GUI/UpdateDate, Value: 1 d, 2010-01-29, stable 
raw

    VirtualBox::Command.stubs(:execute)

    @ed = VirtualBox::ExtraData.new
    @ed["foo"] = "bar"
    @ed.clear_dirty!
  end
  
  context "attributes" do
    should "return parent name if its a VM object" do
      vm = mock("vm")
      vm.stubs(:is_a?).with(VirtualBox::VM).returns(true)
      vm.stubs(:name).returns("FOO")
      
      @ed.parent = vm
      assert_equal "FOO", @ed.parent_name
    end
    
    should "return default otherwise" do
      assert_equal "global", @ed.parent_name
    end
  end
  
  context "relationships" do
    setup do
      @caller = mock("caller")
      @caller.stubs(:name).returns("foocaller")
      
      VirtualBox::Command.stubs(:vboxmanage).returns(@raw)      
    end
    
    context "populating" do
      should "call VBoxManage for the caller" do
        VirtualBox::Command.expects(:vboxmanage).with("getextradata #{@caller.name} enumerate").returns(@raw)
        VirtualBox::ExtraData.populate_relationship(@caller, {})
      end
      
      should "call pairs_to_objects with parent set to the caller" do
        VirtualBox::ExtraData.expects(:parse_kv_pairs).with(@raw, @caller).once
        VirtualBox::ExtraData.populate_relationship(@caller, {})        
      end
      
      should "return an array of ExtraData objects" do
        result = VirtualBox::ExtraData.populate_relationship(@caller, {})
        assert result.is_a?(VirtualBox::ExtraData)
      end
    end
    
    context "saving" do
      should "call save on the ExtraData object" do
        object = mock("object")
        object.expects(:save).once
        
        VirtualBox::ExtraData.save_relationship(@caller, object)
      end
    end
  end
  
  context "destroying (deleting)" do
    setup do
      @key = "foo"
    end
    
    should "call the proper vbox command" do
      VirtualBox::Command.expects(:vboxmanage).with("setextradata global foo")
      assert @ed.delete(@key)
    end
    
    should "remove the key from the hash" do
      assert @ed.has_key?(@key)
      assert @ed.delete(@key)
      assert !@ed.has_key?(@key)
    end
    
    should "raise an exception if true sent to save and error occured" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @ed.delete(@key, true)
      }
    end
    
    should "return false if the command failed" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert !@ed.delete(@key)
    end
  end
  
  context "saving" do
    setup do
      @ed["foo"] = "BAR"
      assert @ed.changed?
    end
    
    should "do nothing if there are no changes" do
      @ed.clear_dirty!
      VirtualBox::Command.expects(:vboxmanage).never
      assert @ed.save
    end
    
    should "call the proper vbox command" do
      VirtualBox::Command.expects(:vboxmanage).with("setextradata global foo BAR")
      assert @ed.save
    end
    
    should "return false if the command failed" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert !@ed.save
    end
    
    should "raise an exception if true sent to save and error occured" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @ed.save(true)
      }
    end
    
    should "clear dirty state" do
      @ed["value"] = "rawr"
      assert @ed.changed?
      assert @ed.save
      assert !@ed.changed?
    end
  end

  context "setting dirty state" do
    setup do
      @ed = VirtualBox::ExtraData.new
    end

    should "not be dirty initially" do
      assert !@ed.changed?
    end
    
    should "be dirty when setting a value" do
      @ed["foo"] = "bar"
      assert @ed.changed?
      assert @ed.changes.has_key?("foo")
    end
  end
  
  context "global extra data" do
    should "call the command, parse it, then turn it into objects" do
      get_seq = sequence("get_seq")
      VirtualBox::Command.expects(:vboxmanage).with("getextradata global enumerate").once.in_sequence(get_seq)
      VirtualBox::ExtraData.expects(:parse_kv_pairs).returns(@ed).once.in_sequence(get_seq)
      assert_equal "bar", VirtualBox::ExtraData.global["foo"]
    end
  end
  
  context "constructor" do
    should "set the parent with the given argument" do
      ed = VirtualBox::ExtraData.new("JOEY")
      assert_equal "JOEY", ed.parent
    end
    
    should "be global by default" do
      ed = VirtualBox::ExtraData.new
      assert_equal "global", ed.parent
    end
  end
  
  context "parsing KV pairs" do
    setup do
      @data = VirtualBox::ExtraData.parse_kv_pairs(@raw)
    end
    
    should "return the proper number of items" do
      # Shows that it skips over non-matching lines as well
      assert_equal 6, @data.length
    end
    
    should "return as an ExtraData Hash" do
      assert @data.is_a?(Hash)
      assert @data.is_a?(VirtualBox::ExtraData)
    end
    
    should "return proper values, trimmed" do
      assert_equal "1 d, 2010-01-29, stable", @data["GUI/UpdateDate"]
    end
    
    should  "send the 2nd param as the parent to the ED object" do
      @data = VirtualBox::ExtraData.parse_kv_pairs(@raw, "FOO")
      assert_equal "FOO", @data.parent
    end
    
    should "return an unchanged ED object" do
      assert !@data.changed?
    end
  end
end