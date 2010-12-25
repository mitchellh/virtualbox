module VirtualBox
  # Represents an VirtualBox "appliance" which is an exported virtual machine or
  # virtual machines. Appliances typically come with an OVF file and one or more
  # compressed hard disks, and can be used to import directly into other VirtualBox
  # installations. Appliances allow for virtual machine portability.
  class Appliance < AbstractModel
    attribute :path
    attribute :interface, :readonly => true, :property => false
    relationship :virtual_systems, :VirtualSystemDescription

    def initialize(*args)
      write_attribute(:interface, Lib.lib.virtualbox.create_appliance)

      initialize_from_path(*args) if args.length == 1

      clear_dirty!
    end

    # Initializes this Appliance instance from a path to an OVF file. This sets
    # up the relationships and so on.
    #
    # @param [String] path Path to the OVF file.
    def initialize_from_path(path)
      # Read in the data from the path
      interface.read(path).wait_for_completion(-1)

      # Interpret the data to fill in the interface properties
      interface.interpret

      # Load the interface attributes
      load_interface_attributes(interface)

      # Fill in the virtual systems
      populate_relationship(:virtual_systems, interface.virtual_system_descriptions)

      # Should be an existing record
      existing_record!
    end

    # Imports the machines associated with this appliance. If a block is given,
    # it will be yielded every percent that the operation progresses. This can be
    # done to check the progress of the import.
    def import(&block)
      interface.import_machines.wait(&block)
    end

    # Exports the machines to the given path. If a block is given, it will be yielded
    # every percent that the operation progresses. This can be done to check the progress
    # of the export in real-time.
    def export(&block)
      interface.write("ovf-1.0", true, path).wait(&block)
    end

    # Adds a VM to the appliance
    def add_machine(vm, options = {})
      sys_desc = vm.interface.export(interface, path)
      options.each do |key, value|
        sys_desc.add_description(key, value, value)
      end
    end
  end
end
