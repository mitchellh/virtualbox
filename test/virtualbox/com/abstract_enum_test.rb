require File.expand_path("../../../test_helper", __FILE__)

class COMAbstractEnumTest < Test::Unit::TestCase
  context "setting up the map" do
    setup do
      @enum = VirtualBox::COM::AbstractEnum
      @enum.reset!
    end

    should "set the map up and be able to access it" do
      @enum.map([:a, :b, :c])
      assert_equal :a, @enum[0]
      assert_equal :b, @enum[1]
      assert_equal :c, @enum[2]
      assert_equal({:a => 0, :b => 1, :c => 2}, @enum.map)
    end

    should "do the reverse mapping of value to index" do
      @enum.map([:a, :b, :c])
      assert_equal 1, @enum.index(:b)
    end

    should "reset the map if another is given" do
      @enum.map([:a])
      @enum.map([:b])
      assert_equal :b, @enum[0]
    end

    should "allow iterating over the enum" do
      array = [:a, :b, :c]
      other_array = []
      @enum.map(array)
      @enum.each do |item|
        other_array << item
      end

      assert_equal array, other_array
    end

    should "include enumerable methods" do
      array = [:a, :b, :c]
      @enum.map(array)

      @enum.each_with_index do |object, index|
        assert_equal array[index], object
      end
    end
  end
end
