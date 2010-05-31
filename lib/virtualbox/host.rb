module VirtualBox
  # Represents information about the host machine. This includes
  # information such as memory available, processors, dvds, network
  # interfaces, etc.
  #
  # This information is different from system properties in that some
  # parts represent data which is stored in the VirtualBox "registry"
  # (such as the dvd drives, host only network interfaces, etc.)
  class Host < AbstractModel
    attribute :interface, :readonly => true, :property => false
    attribute :processor_count, :readonly => true
    attribute :processor_online_count, :readonly => true
    attribute :memory_size, :readonly => true
    attribute :memory_available, :readonly => true
    attribute :operating_system, :readonly => true
    attribute :os_version, :readonly => true
    attribute :utc_time, :readonly => true
    attribute :acceleration_3d_available, :readonly => true

    class << self
      # Populates the system properties relationship for anything
      # which is related to it.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [SystemProperties]
      def populate_relationship(caller, data)
        new(data)
      end

      # Saves the relationship. This simply calls {#save} on the
      # relationship object.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, item)
        item.save
      end
    end

    # Initializes the system properties object. This shouldn't be called
    # directly. Instead `Global#system_properties` should be used to
    # retrieve this object.
    def initialize(raw)
      initialize_attributes(raw)
    end

    # Initializes the attributes of an existing shared folder.
    def initialize_attributes(raw)
      # Save the interface to an attribute
      write_attribute(:interface, raw)

      # Load the attributes from the interface
      load_interface_attributes(interface)

      # Clear dirty and mark as existing
      clear_dirty!
      existing_record!
    end

    # Saves the system properties.
    def save
      save_changed_interface_attributes(interface)
    end
  end
end
