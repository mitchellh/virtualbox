require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')
require 'virtualbox/ext/byte_normalizer'

class ByteNormalizerTest < Test::Unit::TestCase
  class A
    include VirtualBox::ByteNormalizer
  end

  setup do
    @instance = A.new
  end

  should "convert megabytes to bytes" do
    expected = {
      1 => 1_048_576,
      345.4 => 362_178_150.4
    }

    expected.each do |input, out|
      assert_equal out, @instance.megabytes_to_bytes(input)
    end
  end
end