module VirtualBox
  module COM
    module Implementer
      class Base < AbstractImplementer
        # Finds and returns the `COM::Interface` class associated with the type.
        # If the class does not exist, a `NameError` will be raised.
        #
        # @return [Class]
        def interface_klass(type)
          COM::Interface.const_get(type)
        end

        # Gives the C type and inferred type of a parameter type. Quite confusing
        # since the terminology is not consistent, but hopefully these examples
        # will help:
        #
        #   type => [pointer_type, internal_type]
        #   :int => [:int, :int]
        #   :MyStruct => [:pointer, :struct]
        #   :unicode_string => [:pointer, :unicode_string]
        #
        def infer_type(type)
          c_type = type

          begin
            if type == WSTRING
              # Handle strings as pointer types
              c_type = :pointer
            else
              # Try to get the class from the interfaces
              interface = COM::Interface.const_get(type)

              c_type = :pointer

              # Depending on the class type, we're either dealing with an interface
              # or an enum
              type = :interface if interface.superclass == COM::AbstractInterface
              type = :enum if interface.superclass == COM::AbstractEnum
            end
          rescue NameError
            # Do nothing
          end

          [c_type, type]
        end

      end
    end
  end
end
