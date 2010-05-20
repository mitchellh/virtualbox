module VirtualBox
  module COM
    class Util
      class <<self
        # Returns a boolean true/false whether the given COM interface
        # exists.
        #
        # @return [Boolean]
        def interface?(name)
          COM::Interface.const_get(name.to_sym)
          true
        rescue NameError
          false
        end

        # Gets an interface within the current version namespace.
        def versioned_interface(interface)
          Object.module_eval("::VirtualBox::COM::Interface::#{version_const}::#{interface}")
        end

        # Returns a namespace representation for a version.
        def version_const
          "Version_" + @__version.upcase.gsub(".", "_")
        end

        def set_interface_version(version)
          @__version = version
        end
      end
    end
  end
end