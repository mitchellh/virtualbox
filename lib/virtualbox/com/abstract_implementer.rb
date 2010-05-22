module VirtualBox
  module COM
    # Base class for a COM interface implementer. Any child of this class is
    # responsible for properly handling the various method and propery calls
    # of a given {AbstractInterface} and making them do actual work.
    #
    # This abstraction is necessary to change the behavior of calls between
    # Windows (COM) and Unix (XPCOM), which have different calling conventions.
    class AbstractImplementer
      attr_reader :interface
      attr_reader :lib

      # Initializes an implementer for the given {AbstractInterface}. The
      # implementor's other methods, such as {read_property} or
      # {call_function} are responsible for executing the said action on
      # the interface.
      #
      # @param [AbstractInterface] interface
      def initialize(interface, lib)
        @interface = interface
        @lib = lib
      end

      # Read a property of the interface.
      #
      # @param [Symbol] name The propery name
      def read_property(name, opts)
      end

      # Writes a property of the interface.
      #
      # @param [Symbol] name The property name
      # @param [Object] value The value to set
      def write_property(name, value, opts)
      end

      # Calls a function on the interface.
      #
      # @param [Symbol] name The function name
      # @param [Array] args The arguments to the function
      def call_function(name, args, opts)
      end
    end
  end
end
