# A super simple ordered hash implementation. This class probably
# isn't useful outside of these testing scripts, since only the bare
# minimum is implemented.
#
# The ordered hash is implemented by keeping the key/values in an
# array where each element is an array of format [key,value]. This
# forces the keys to be in the proper order, paired with their
# values.
class OrderedHash
  include Enumerable

  def initialize
    @items = []
  end

  def []=(key,value)
    # Try to update it in the array if it exists
    @items.each_with_index do |data, index|
      return @items[index][1] = value if data[0] == key
    end

    # Otherwise just add it to the list
    @items << [key, value]
  end

  def [](key)
    @items.each do |k, v|
      return v if k == key
    end

    nil
  end

  def each(&block)
    @items.each(&block)
  end
end
