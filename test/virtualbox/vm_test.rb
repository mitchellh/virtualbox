require File.join(File.dirname(__FILE__), '..', 'test_helper')

class VMTest < Test::Unit::TestCase
  context "parsing the showvminfo output" do
    should "ignore quotes for multi-word keys or values" do
      result = VirtualBox::VM.parse_vm_info('"foo bar"="baz"')
      assert_equal 1, result.length
      assert_equal "baz", result["foo bar"]
    end
    
    should "ignore the lines which aren't the proper format" do
      result = VirtualBox::VM.parse_vm_info(<<-block)
This should not be parsed
Neither should this

foo=bar
block

      assert_equal 1, result.length
      assert_equal "bar", result["foo"]
    end
  end
end