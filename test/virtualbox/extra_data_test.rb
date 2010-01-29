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

    @ed = VirtualBox::ExtraData.new({
      :key   => "foo",
      :value => "bar"
    })
  end
  
  context "validations" do
    should "be valid with all fields" do
      assert @ed.valid?
    end
    
    should "be invalid with no key" do
      @ed.key = nil
      assert !@ed.valid?
    end
    
    should "be invalid with no value" do
      @ed.value = nil
      assert !@ed.valid?
    end
  end
  
  context "destroying" do
    should "call the proper vbox command" do
      VirtualBox::Command.expects(:vboxmanage).with("setextradata global foo")
      assert @ed.destroy
    end
    
    should "raise an exception if true sent to save and error occured" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @ed.destroy(true)
      }
    end
    
    should "destroy using the old key if it was changed" do
      @ed.key = "CHANGED"
      VirtualBox::Command.expects(:vboxmanage).with("setextradata global foo")
      @ed.destroy
    end
  end
  
  context "saving" do
    should "call destroy first if the key changed" do
      @ed.key = "CHANGED"
      @ed.expects(:destroy).once
      @ed.save
    end
    
    should "return false and not call vboxmanage if invalid" do
      VirtualBox::Command.expects(:vboxmanage).never
      @ed.expects(:valid?).returns(false)
      assert !@ed.save
    end
    
    should "raise a ValidationFailedException if invalid and raise_errors is true" do
      @ed.expects(:valid?).returns(false)
      assert_raises(VirtualBox::Exceptions::ValidationFailedException) {
        @ed.save(true)
      }
    end
    
    should "call the proper vbox command" do
      VirtualBox::Command.expects(:vboxmanage).with("setextradata global foo bar")
      assert @ed.save
    end
    
    should "raise an exception if true sent to save and error occured" do
      VirtualBox::Command.stubs(:vboxmanage).raises(VirtualBox::Exceptions::CommandFailedException)
      assert_raises(VirtualBox::Exceptions::CommandFailedException) {
        @ed.save(true)
      }
    end
    
    should "clear dirty state" do
      @ed.value = "rawr"
      assert @ed.changed?
      assert @ed.save
      assert !@ed.changed?
    end
  end
  
  context "global extra data" do
    should "call the command, parse it, then turn it into objects" do
      get_seq = sequence("get_seq")
      VirtualBox::Command.expects(:vboxmanage).with("getextradata global enumerate").once.in_sequence(get_seq)
      VirtualBox::ExtraData.expects(:parse_kv_pairs).once.in_sequence(get_seq)
      VirtualBox::ExtraData.expects(:pairs_to_objects).once.returns("foo").in_sequence(get_seq)
      assert_equal "foo", VirtualBox::ExtraData.global
    end
  end
  
  context "constructor" do
    should "populate the attributes with given data" do
      ed = VirtualBox::ExtraData.new({ :key => "foo", :value => "bar" })
      assert_equal "foo", ed.key
      assert_equal "bar", ed.value
    end
  end
  
  context "converting pairs to objects" do
    setup do
      @data = VirtualBox::ExtraData.parse_kv_pairs(@raw)
      @objects = VirtualBox::ExtraData.pairs_to_objects(@data)
    end
    
    should "return an array of ExtraData objects" do
      assert @objects.is_a?(Array)
      assert @objects.all? { |o| o.is_a?(VirtualBox::ExtraData) }
    end
    
    should "have proper data on extradata objects" do
      object = @objects[0]
      assert_equal "GUI/SuppressMessages", object.key
      assert_equal ",confirmInputCapture,remindAboutAutoCapture,confirmRemoveMedium,remindAboutInaccessibleMedia,confirmGoingFullscreen,remindAboutMouseIntegrationOn", object.value
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
    
    should "return as a hash" do
      assert @data.is_a?(Hash)
    end
    
    should "return proper values, trimmed" do
      assert_equal "1 d, 2010-01-29, stable", @data["GUI/UpdateDate"]
    end
  end
end