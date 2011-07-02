module VirtualBox
  module COM
    class Util
      class << self
        # This keeps a hash of all the loaded interface classes.
        # Example:
        #
        #   loaded_interfaces[:VirtualBox]
        #
        # This will return either nil or the class representing this
        # interface.
        def loaded_interfaces
          @loaded_interfaces ||= {}
        end

        # Gets an interface within the current version namespace.
        def versioned_interface(interface)
          loaded_interfaces[interface] ||= load_interface(interface)
        end

        # This loads the interface with the given name and returns it.
        # This is different than `versioned_interface` since this will not
        # cache any results.
        def load_interface(interface)
          # This require will only run once. If we repeat it, it is not
          # loaded again
          require "virtualbox/com/interface/#{@__version}/#{interface}"

          # Find the module based on the version and name and return it
          Object.module_eval("::VirtualBox::COM::Interface::#{version_const}::#{interface}")
        end

        # Returns the current version
        def version
          @__version
        end

        # Returns a namespace representation for a version.
        def version_const
          "Version_" + @__version.upcase.gsub(".", "_")
        end

        def set_interface_version(version)
          # Set the new version
          @__version = version

          # Clear the loaded interface cache to force each interface
          # to be reloaded
          loaded_interfaces.clear
        end
      end
    end
  end
end
