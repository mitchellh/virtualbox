require File.expand_path("../../../test_helper", __FILE__)
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

  should "convert bytes to megabytes" do
    expected = {
      1_048_576 => 1,
      362_178_150.4 => 345.4
    }

    expected.each do |input, out|
      assert_equal out, @instance.bytes_to_megabytes(input)
    end
  end
end
