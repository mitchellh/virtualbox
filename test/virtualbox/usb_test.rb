require File.join(File.dirname(__FILE__), '..', 'test_helper')

class UsbTest < Test::Unit::TestCase
  setup do
    @caller = mock("caller")
    @caller.stubs(:name).returns("foo")
  end

  context "populating relationships" do
    setup do
      @value = VirtualBox::USB.populate_relationship(@caller, mock_xml_doc)
    end

    should "create the correct amount of objects" do
      assert_equal 2, @value.length
    end

    should "not be dirty initially" do
      assert !@value[0].changed?
    end

    should "be an existing record" do
      assert !@value[0].new_record?
    end

    should "parse attributes correctly" do
      assert_equal 'true', @value[0].active
      assert_equal 'Apple, Inc', @value[0].manufacturer
      assert_equal 'Apple, Inc Apple Keyboard [0069]', @value[0].name
      assert_equal @caller, @value[0].parent
      assert_equal 'Apple Keyboard', @value[0].product
      assert_equal 'no', @value[0].remote
    end
  end
end