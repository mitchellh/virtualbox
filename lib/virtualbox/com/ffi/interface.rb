require 'ffi'

module VirtualBox
  module COM
    module FFI
      extend ::FFI::Library

      # FFI specific types
      NSRESULT_TYPE = :uint

      # Creates all the FFI classes for a given version.
      def self.for_version(version, &block)
        @__module = Module.new
        ::VirtualBox::COM::Util.set_interface_version(version)
        const_set(::VirtualBox::COM::Util.version_const, @__module)
        instance_eval(&block)
        @__module = Kernel
      end

      # Returns a Class which creates an FFI interface to the specified
      # com interface and potentially a parent class as well.
      def self.create_interface(interface, parent=nil)
        klass = Class.new(Interface)
        @__module.const_set(interface, klass)
        klass.com_interface(interface, parent)
        klass
      end

      # Represents a VirtualBox XPCOM C interface, which is a C struct
      # which emulates an object (a struct with function pointers
      # and getters/setters). This class does **a lot** of magic which pretty
      # much represents everything wrong about ruby programmers, but keep
      # in mind it is well tested and well commented, and the meta-programming
      # was done out of a need to keep things DRY between Windows and Unix
      # operating systems.
      class Interface
        extend ::FFI::Library

        attr_reader :vtbl_parent
        attr_reader :vtbl

        class <<self
          # Sets up the args to the FFI::Struct `layout` method. This
          # method defines all the callbacks necessary for working with
          # FFI and also sets up any layout args to send in. The way the
          # XPCOM C structs are setup, the properties are first, in
          # `GetFoo` and `SetFoo` format. And the functions are next. They are
          # put into the struct in the order defined in the {AbstractInterface}.
          def com_interface(interface, parent=nil)
            # Create the parent class and vtbl class
            interface = ::VirtualBox::COM::Util.versioned_interface(interface)
            define_vtbl_parent_for_interface(interface)
            define_vtbl_for_interface(interface, parent)
          end

          # Creates the parent of the vtbl class associated with a given
          # interface.
          def define_vtbl_parent_for_interface(interface)
            @vtbl_parent_klass = Class.new(::FFI::Struct)
            @vtbl_parent_klass.layout(:vtbl, :pointer)

            # Set the constant
            const_set("VtblParent", @vtbl_parent_klass)
          end

          # Creates the vtbl class associated with a given interface.
          def define_vtbl_for_interface(interface, parent=nil)
            # Define the properties, then the functions, since thats the order
            # the FFI structs are in
            layout_args.clear
            define_interface_parent(parent)
            define_interface_properties(interface)
            define_interface_functions(interface)

            # Finally create the classes (the struct and the structs vtbl)
            @vtbl_klass = Class.new(::FFI::Struct)

            # Set the constant within this class
            const_set("Vtbl", @vtbl_klass).layout(*layout_args.flatten)
          end

          # Defines the parent item of the layout. Since the VirtualBox XPCOM C
          # library emulates an object-oriented environment using structs, the parent
          # instance is pointed to by the first member of the struct. This method
          # sets up that member.
          #
          # @param [Symbol] parent The name of the parent represented by a symbol
          def define_interface_parent(parent)
            return if parent.nil?

            parent_klass = Object.module_eval("::VirtualBox::COM::FFI::#{::VirtualBox::COM::Util.version_const}::#{parent}::Vtbl")
            layout_args << [:superklass, parent_klass]
          end

          # Defines all the properties on a com interface.
          def define_interface_properties(interface)
            interface.properties.each do |name, opts|
              # Define the getter
              define_interface_function("get_#{name}".to_sym, opts[:value_type])

              # Define the setter unless the property is readonly
              define_interface_function("set_#{name}".to_sym, nil, [opts[:value_type]]) unless opts[:opts] && opts[:opts][:readonly]
            end
          end

          # Defines all the functions on a com interface.
          def define_interface_functions(interface)
            interface.functions.each do |name, opts|
              # Define the function
              define_interface_function(name, opts[:value_type], opts[:spec].dup)
            end
          end

          # Defines a single function of a com interface
          def define_interface_function(name, return_type, spec=[])
            # Append the return type to the spec as an out parameter (this is how
            # the C API handles it)
            spec << [:out, return_type] unless return_type.nil?

            # Define the "callback" type for the FFI module
            callback(name, Util.spec_to_ffi(spec), NSRESULT_TYPE)

            # Add to the layout args
            layout_args << [name, name]
          end

          # Returns an array of the layout args to send to `layout` eventually.
          #
          # @return [Array]
          def layout_args
            @_layout_args ||= []
          end
        end

        # Initializes the interface to the FFI struct with the given pointer. The
        # pointer is used to initialize the VtblParent which is used to initialize
        # the Vtbl itself.
        def initialize(pointer)
          initialize_vtbl(pointer)
        end

        def initialize_vtbl(pointer)
          klass = self.class
          @vtbl_parent = klass::VtblParent.new(pointer)
          @vtbl = klass::Vtbl.new(vtbl_parent[:vtbl])
        end
      end
    end
  end
end