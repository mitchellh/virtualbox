module VirtualBox
  module COM
    module Implementer
      class FFI < Base
        attr_reader :ffi_interface

        # Initializes the FFI implementer which takes an {VirtualBox::COM::AbstractInterface AbstractInterface}
        # instant and FFI pointer and initializes everything required to
        # communicate with that interface via FFI.
        #
        # @param [VirtualBox::COM::AbstractInteface] inteface
        # @param [FFI::Pointer] pointer
        def initialize(interface, lib_base, pointer)
          super(interface, lib_base)

          @ffi_interface = ffi_class.new(pointer)
        end

        # Gets the FFI struct class associated with the interface. This works
        # by stripping the namespace off of the interface class and finding that
        # same class within the `COM::FFI` namespace. For example:
        # `VirtualBox::COM::Interface::Session` becomes `VirtualBox::COM::FFI::Session`
        #
        # @return [Class]
        def ffi_class
          # Take off the last part of the class, so `Foo::Bar::Baz` becomes
          # just `Baz`
          klass_name = interface.class.to_s.split("::").last

          # Get the associated FFI class
          COM::FFI.const_get(::VirtualBox::COM::Util.version_const).const_get(klass_name)
        end

        # Reads a property from the interface with the given name.
        def read_property(name, opts)
          call_vtbl_function("get_#{name}".to_sym, [[:out, opts[:value_type]]])
        end

        # Writes a property to the interface with the given name and value.
        def write_property(name, value, opts)
          call_vtbl_function("set_#{name}".to_sym, [opts[:value_type]], [value])
        end

        # Calls a function from the interface with the given name and args. This
        # method is called from the {AbstractInterface}.
        def call_function(name, args, opts)
          spec = opts[:spec].dup
          spec << [:out, opts[:value_type]] if !opts[:value_type].nil?

          call_vtbl_function(name.to_sym, spec, args)
        end

        # Calls a function on the vtbl of the FFI struct. This function handles
        # converting the spec to proper arguments and also handles reading out
        # the arguments, dereferencing pointers, setting up objects, etc. so that
        # the return value is filled with nicely formatted Ruby objects.
        #
        # If the vtbl function being called only has one out parameter, then the
        # return value will be that single object. If it has multiple, then it will
        # be an array of objects.
        def call_vtbl_function(name, spec, args=[])
          # Get the "formal argument" list. This is the list of arguments to send
          # to the actual function based on the spec. This contains pointers, some
          # arguments from `args`, etc.
          formal_args = spec_to_args(spec, args)

          # Call the function.
          logger.debug("FFI call: #{name} #{args.inspect} #{formal_args.inspect}")
          call_and_check(name, ffi_interface.vtbl_parent, *formal_args)

          # Extract the values from the formal args array, again based on the
          # spec (and the various :out parameters)
          result = values_from_formal_args(spec, formal_args)
          logger.debug("    = #{result.inspect}")
          result
        end

        #############################################################
        # Internal Methods, a.k.a. unless you're hacking on the code of this
        # library, you should do well to leave these alone =]
        #############################################################

        # Checks the result of a method call for an error, and if an error
        # occurs, then raises an exception.
        def call_and_check(function, *args)
          result = ffi_interface.vtbl[function].call(*args)

          # Ignore NS_ERROR_NOT_IMPLEMENTED, since it seems to be raised for
          # things which aren't really exceptional
          if result != 2147500033 && (result & 0x8000_0000) != 0
            # Failure, raise exception with details of the error
            raise exception_map(result).new({
              :function => function.to_s,
              :result_code => result
            })
          end
        end

        # Maps a result code to an exception. If no mapping currently exists,
        # then a regular {Exceptions::FFIException} is returned.
        #
        # @param [Fixnum] code Result code
        # @return [Class]
        def exception_map(code)
          map = {
            0x80BB_0001 => Exceptions::ObjectNotFoundException,
            0x80BB_0002 => Exceptions::InvalidVMStateException,
            0x80BB_0003 => Exceptions::VMErrorException,
            0x80BB_0004 => Exceptions::FileErrorException,
            0x80BB_0005 => Exceptions::SubsystemException,
            0x80BB_0006 => Exceptions::PDMException,
            0x80BB_0007 => Exceptions::InvalidObjectStateException,
            0x80BB_0008 => Exceptions::HostErrorException,
            0x80BB_0009 => Exceptions::NotSupportedException,
            0x80BB_000A => Exceptions::XMLErrorException,
            0x80BB_000B => Exceptions::InvalidSessionStateException,
            0x80BB_000C => Exceptions::ObjectInUseException
          }

          map[code] || Exceptions::FFIException
        end

        # Converts a function spec to a proper argument list with the given
        # arguments.
        #
        # @return [Array]
        def spec_to_args(spec, args=[])
          args = args.dup

          results = spec.inject([]) do |results, item|
            single_type_to_arg(args, item, results)
          end
        end

        # Converts a single type and args list to the proper formal args list
        def single_type_to_arg(args, item, results)
          if item.is_a?(Array) && item[0] == :out
            if item[1].is_a?(Array)
              # For arrays we need two pointers: one for size, and one for the
              # actual array
              results << pointer_for_type(T_UINT32)
              results << pointer_for_type(item[1][0])
            else
              results << pointer_for_type(item[1])
            end
          elsif item.is_a?(Array) && item.length == 1
            # Array argument
            data = args.shift

            # First add the length of the array
            results << data.length

            # Create the array
            c_type, type = infer_type(item.first)

            # If its a regular type (int, bool, etc.) then just make it an
            # array of that
            if type != :interface
              results << data.inject([]) do |converted_data, single|
                single_type_to_arg([single], item[0], converted_data)
              end
            else
              # Then convert the rest into a raw MemoryPointer
              array = ::FFI::MemoryPointer.new(:pointer, data.length)
              data.each_with_index do |datum, i|
                converted = []
                single_type_to_arg([datum], item.first, converted)
                array[i].put_pointer(0, converted.first)
              end

              results << array
            end
          elsif item == WSTRING
            # We have to convert the arg to a unicode string
            results << string_to_utf16(args.shift)
          elsif item == T_BOOL
            results << (args.shift ? 1 : 0)
          elsif item.to_s[0,1] == item.to_s[0,1].upcase
            # Try to get the class from the interfaces
            interface = interface_klass(item.to_sym)

            if interface.superclass == COM::AbstractInterface
              # For interfaces, get the instance, then dig deep to get the pointer
              # to the VtblParent, which is what the API expects
              instance = args.shift

              results << if !instance.nil?
                instance.implementer.ffi_interface.vtbl_parent
              else
                # If the argument was nil, just pass a nil pointer as the argument
                nil
              end
            elsif interface.superclass == COM::AbstractEnum
              # For enums, we need the value of the enum
              results << interface.index(args.shift.to_sym)
            end
          else
            # Simply replace spec item with next item in args
            # list
            results << args.shift
          end
        end

        # Takes a spec and a formal parameter list and returns the output from
        # a function, properly dereferencing any output pointers.
        #
        # @param [Array] specs The parameter spec for the function
        # @param [Array] formal The formal parameter list
        def values_from_formal_args(specs, formal)
          return_values = []
          i = 0
          specs.each do |spec|
            # Output parameters are all we care about
            if spec.is_a?(Array) && spec[0] == :out
              if spec[1].is_a?(Array)
                # We are dealing with formal[i] and formal[i+1] here, where
                # the first has the size and the second has the contents
                return_values << dereference_pointer_array(formal[i+1], spec[1][0], dereference_pointer(formal[i], T_UINT32))

                # Increment once more to skip the size param
                i += 1
              else
                return_values << dereference_pointer(formal[i], spec[1])
              end
            end

            i += 1
          end

          if return_values.empty?
            nil
          elsif return_values.length == 1
            return_values.first
          else
            return_values
          end
        end

        # Dereferences a pointer with a given type into a proper Ruby object.
        # If the type is a standard primitive of Ruby-FFI, it simply calls the
        # proper `get_*` method on the pointer. Otherwise, it calls a
        # `read_*` on the Util class.
        #
        # @param [FFI::MemoryPointer] pointer
        # @param [Symbol] type The type of the pointer
        # @return [Object] The value of the dereferenced pointer
        def dereference_pointer(pointer, type)
          c_type, inferred_type = infer_type(type)

          if pointer.respond_to?("get_#{inferred_type}".to_sym)
            # This handles reading the typical times such as :uint, :int, etc.
            result = pointer.send("get_#{inferred_type}".to_sym, 0)
            result = !(result == 0) if type == T_BOOL
            result
          else
            send("read_#{inferred_type}".to_sym, pointer, type)
          end
        end

        # Dereferences an array out of a pointer into an array of proper Ruby
        # objects.
        #
        # @param [FFI::MemoryPointer] pointer
        # @param [Symbol] type The type of the pointer
        # @param [Fixnum] length The length of the array
        # @return [Array<Object>]
        def dereference_pointer_array(pointer, type, length)
          # If there are no items in the pointer, just return an empty array
          return [] if length == 0

          c_type, inferred_type = infer_type(type)

          array_pointer = pointer.get_pointer(0)
          if array_pointer.respond_to?("get_array_of_#{inferred_type}".to_sym)
            # This handles reading the typical times such as :uint, :int, etc.
            array_pointer.send("get_array_of_#{inferred_type}".to_sym, 0, length)
          else
            send("read_array_of_#{inferred_type}".to_sym, array_pointer, type, length)
          end
        end

        # Converts a symbol type into a MemoryPointer and yield a block
        # with the pointer, the C type, and the FFI type
        def pointer_for_type(type)
          c_type, type = infer_type(type)

          # Create the pointer, yield, returning the result of the block
          # if a block is given, or otherwise just returning the pointer
          # and inferred type
          pointer = ::FFI::MemoryPointer.new(c_type)
          if block_given?
            yield pointer, type
          else
            pointer
          end
        end

        # Converts a ruby string to a UTF16 string
        #
        # @param [String] Ruby String object
        # @return [::FFI::Pointer]
        def string_to_utf16(string)
          return nil if string.nil?

          ptr = pointer_for_type(:pointer)
          lib.xpcom[:pfnUtf8ToUtf16].call(string, ptr)
          ptr.read_pointer()
        end

        # Converts a UTF16 string to UTF8
        def utf16_to_string(pointer)
          result_pointer = pointer_for_type(:pointer)
          lib.xpcom[:pfnUtf16ToUtf8].call(pointer, result_pointer)
          lib.xpcom[:pfnUtf16Free].call(pointer)
          result_pointer.read_pointer().read_string().to_s
        end

        # Reads a unicode string value from a pointer to that value.
        #
        # @return [String]
        def read_unicode_string(ptr, original_type=nil)
          address = ptr.get_pointer(0)
          return "" if address.null?
          utf16_to_string(address)
        end

        # Reads an interface from the pointer
        #
        # @return [::FFI::Struct]
        def read_interface(ptr, original_type)
          ptr = ptr.get_pointer(0)
          return nil if ptr.null?

          klass = interface_klass(original_type)
          klass.new(self.class, lib, ptr)
        end

        # Reads an enum
        #
        # @return [Symbol]
        def read_enum(ptr, original_type)
          klass = interface_klass(original_type)
          klass[ptr.get_uint(0)]
        end

        # Reads an array of enums
        #
        # @return [Array<Symbol>]
        def read_array_of_enum(ptr, type, length)
          klass = interface_klass(type)
          ptr.get_array_of_uint(0, length).collect do |value|
            klass[value]
          end
        end

        # Reads an array of structs from a pointer
        #
        # @return [Array<::FFI::Struct>]
        def read_array_of_interface(ptr, type, length)
          klass = interface_klass(type)
          ptr.get_array_of_pointer(0, length).collect do |single_pointer|
            klass.new(self.class, lib, single_pointer)
          end
        end

        # Reads an array of strings from a pointer
        #
        # @return [Array<String>]
        def read_array_of_unicode_string(ptr, type, length)
          ptr.get_array_of_pointer(0, length).collect do |single_pointer|
            if single_pointer.null?
              nil
            else
              utf16_to_string(single_pointer)
            end
          end
        end
      end
    end
  end
end
