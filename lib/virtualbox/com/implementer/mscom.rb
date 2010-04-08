module VirtualBox
  module COM
    module Implementer
      class MSCOM < Base
        attr_reader :lib
        attr_reader :object

        # Initializes the MSCOM implementer.
        #
        # @param [AbstractInterface] inteface
        # @param [FFI::Pointer] pointer
        def initialize(interface, lib_base, object)
          super(interface)

          @lib = lib_base
          @object = object
        end

        # Reads a property from the interface with the given name.
        def read_property(name, opts)
          # First get the basic value from the COM object
          value = @object[COM::FFI::Util.camelize(name.to_s)]

          # Then depending on the value type, we either return as-is or
          # must wrap it up in another interface class
          returnable_value(value, opts[:value_type])
        end

        # Writes a property from the interface with the given name and
        # value.
        def write_property(name, value, opts)
          # Set the property with a prepared value
          @object[COM::FFI::Util.camelize(name.to_s)] = spec_to_args([opts[:value_type]], [value]).first
        end

        # Calls a function from the interface with the given name
        def call_function(name, args, opts)
          # Convert args to proper values to send and send em!
          args = spec_to_args(opts[:spec], args)
          value = @object.send(COM::FFI::Util.camelize(name.to_s), *args)

          # TODO: Multiple return values
          returnable_value(value, opts[:value_type])
        end

        #############################################################
        # Internal Methods, a.k.a. unless you're hacking on the code of this
        # library, you should do well to leave these alone =]
        #############################################################

        # Takes a function spec and an argument list. This handles properly converting
        # enums to ints and {AbstractInterface}s to proper MSCOM interfaces.
        def spec_to_args(spec, args)
          args = args.dup

          # First remove all :out parameters from the spec, since those are of no
          # concern for MSCOM at this point
          spec = spec.collect do |item|
            if item.is_a?(Array) && item[0] == :out
              nil
            else
              item
            end
          end.compact

          spec = spec.collect do |item|
            if item == T_BOOL
              args.shift ? 1 : 0
            elsif item.to_s[0,1] == item.to_s[0,1].upcase
              # Try to get the class from the interfaces
              interface = interface_klass(item.to_sym)

              if interface.superclass == COM::AbstractInterface
                # For interfaces, get the instance, then dig deep to get the pointer
                # to the VtblParent, which is what the API expects
                instance = args.shift

                if !instance.nil?
                  # Get the actual MSCOM object, rather than the AbstractInterface
                  instance.implementer.object
                else
                  # If the argument was nil, just pass a nil pointer as the argument
                  nil
                end
              elsif interface.superclass == COM::AbstractEnum
                # For enums, we need the value of the enum
                interface.index(args.shift.to_sym)
              end
            else
              # Simply replace spec item with next item in args
              # list
              args.shift
            end
          end
        end

        # Takes a value (returned from a WIN32OLE object) and a type and converts
        # to a proper ruby return value type.
        def returnable_value(value, type)
          # Types which are void or nil just return
          return nil if type.nil? || type == :void

          klass = type.is_a?(Array) ? type.first : type
          ignore, inferred_type = infer_type(klass)

          array_of = type.is_a?(Array) ? "array_of_" : ""
          send("read_#{array_of}#{inferred_type}", value, type)
        end

        def read_unicode_string(value, type)
          # Return as-is
          value
        end

        def read_char(value, type)
          # Convert to a boolean
          !(value == "0")
        end

        def read_ushort(value, type)
          value.to_i
        end

        def read_uint(value, type)
          value.to_i
        end

        def read_ulong(value, type)
          value.to_i
        end

        def read_int(value, type)
          value.to_i
        end

        def read_long(value, type)
          value.to_i
        end

        def read_enum(value, type)
          interface_klass(type)[value]
        end

        def read_interface(value, type)
          return nil if value.nil?
          interface_klass(type).new(self.class, lib, value)
        end

        def read_array_of_unicode_string(value, type)
          # Return as-is, since MSCOM returns ruby strings!
          value
        end

        def read_array_of_interface(value, type)
          klass = interface_klass(type.first)
          value.collect do |item|
            if !item.nil?
              klass.new(self.class, lib, item)
            end
          end
        end
      end
    end
  end
end