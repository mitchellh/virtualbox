module VirtualBox
  module COM
    # Base class for a COM (component object model) interface class. This
    # abstraction is necessary to maintain a common ground between
    # Windows COM usage and the VirtualBox C API for unix based systems.
    #
    # # Defining an Interface
    #
    # Defining an interface is done by subclassing AbstractInterface and
    # using the provided class methods to define the COM methods and
    # properties. A small example class is shown below:
    #
    #     class Time < AbstractInterface
    #       function :now, [[:out, :uint]]
    #       property :hour, :uint
    #     end
    #
    # # Accessing an Interface
    #
    # Interfaces are never accessed directly. Instead, an {InterfaceRunner}
    # should be used. Depending on the OS of the running system, the VirtualBox
    # gem will automatically either load the MSCOM interface (on Windows)
    # or the XPCOM interface (on Unix). One loaded, interfaces can simply be
    # accessed:
    #
    #     # Assume `time` was retrieved already
    #     puts time.foo.to_s
    #     time.hour = 20
    #     x = time.now
    #
    # The above example shows how the properties and functions can be used
    # with a given interface.
    #
    class AbstractInterface
      attr_reader :implementer
      attr_reader :lib

      class << self
        # Adds a function to the interface with the given name and function
        # spec. The spec determines the arguments required, the order they
        # are required in, and any out-arguments.
        def function(name, type, spec, opts={})
          members << [name, {
            :type => :function,
            :value_type => type,
            :spec => spec,
            :opts => opts
          }]

          # Define the method to call the function
          define_method(name) { |*args| call_function(name, *args) }
        end

        # Adds a property to the interface with the given name, type, and
        # options.
        def property(name, type, opts={})
          members << [name, {
            :type => :property,
            :value_type => type,
            :opts => opts
          }]

          # Define the method to read the property
          define_method(name) { read_property(name) }

          # Define method to write the property
          define_method("#{name}=".to_sym) { |value| write_property(name, value) } unless opts[:readonly]
        end

        # Returns the information for a given member
        #
        # @return [Hash]
        def member(name)
          members.each do |current_name, opts|
            if name == current_name
              return opts
            end
          end

          nil
        end

        # Returns the members of the interface as an array.
        #
        # @return [Array]
        def members
          @members ||= []
        end

        # Returns the functions of the interface as an array in the order they
        # were defined.
        #
        # @return [Array]
        def functions
          members.find_all do |data|
            data[1][:type] == :function
          end
        end

        # Returns the properties of the interface as an array in the order they
        # were defined.
        #
        # @return [Array]
        def properties
          members.find_all do |data|
            data[1][:type] == :property
          end
        end
      end

      # Initializes the interface with the given implementer
      def initialize(implementer, lib, *args)
        # Instantiate the implementer and set it
        @lib = lib
        @implementer = implementer.new(self, lib, *args)
      end

      # Reads a property with the given name by calling the read_property
      # method on the implementer.
      def read_property(name)
        lib.on_lib_thread do
          # Just call it on the implementer
          @implementer.read_property(name, member(name))
        end
      end

      # Writes a property with the given name and value by calling the
      # `write_property` method on the implementer.
      def write_property(name, value)
        lib.on_lib_thread do
          @implementer.write_property(name, value, member(name))
        end
      end

      # Calls a function with the given name by calling call_function on the
      # implementer.
      def call_function(name, *args)
        lib.on_lib_thread do
          @implementer.call_function(name, args, member(name))
        end
      end

      # Returns a boolean if a given function exists or not
      def has_function?(name)
        info = member(name)
        !info.nil? && info[:type] == :function
      end

      # Returns a boolean if a given property exists or not.
      def has_property?(name)
        info = member(name)
        !info.nil? && info[:type] == :property
      end

      # Returns the member of the interface specified by name. This simply
      # calls {AbstractInterface.member}
      def member(name)
        self.class.member(name)
      end

      # Returns the members of the interface as an array. This simply calls
      # {AbstractInterface.members}.
      def members
        self.class.members
      end

      # Concise inspect
      def inspect
        "#<#{self.class.name}>"
      end
    end
  end
end
