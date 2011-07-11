module VirtualBox
  module COM
    # Represents a C enum type. Provides functionality to easily convert
    # an int value to its proper symbol within the enum.
    class AbstractEnum
      extend Enumerable

      class << self
        # Defines the mapping of int => symbol for the given Enum.
        # The parameter to this can be an Array or Hash or anything which
        # can be indexed with `[]` and an integer and returns a value of
        # some sort. If value is left nil, it will return the current mapping
        def map(value = nil)
          if value
            # Convert the array to a hash of equal structure
            if value.is_a?(Array)
              result = {}
              value.each_index do |i|
                result[value[i]] = i
              end

              value = result
            end

            @map = value if value
          end

          @map
        end

        # Returns the symbol associatd with the given key
        def [](index)
          @map.each do |key, value|
            return key if value == index
          end

          nil
        end

        # Returns the index associated with a value
        def index(key)
          @map[key]
        end

        # Iterate over the enum, yielding each item to a block.
        def each
          @map.each do |key, value|
            yield key
          end
        end

        # Provided mostly for testing purposes only, but resets the mapping
        # to nil.
        def reset!
          @map = nil
        end
      end
    end
  end
end
