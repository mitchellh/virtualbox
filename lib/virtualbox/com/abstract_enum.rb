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
          @map = value if value
          @map
        end

        # Returns the symbol associatd with the given key
        def [](key)
          @map[key]
        end

        # Returns the index associated with a value
        def index(key)
          @map.index(key)
        end

        # Iterate over the enum, yielding each item to a block.
        def each
          @map.each do |key|
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
