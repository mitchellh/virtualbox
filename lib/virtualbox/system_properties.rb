module VirtualBox
  # Represents the system properties associated with this VirtualBox
  # installation. Many of these properties are readonly and represent
  # limits on the system (max RAM available, max CPU, etc.). There are
  # also configurable options which can be saved such as the default
  # hard disk folder, or default machine folder.
  class SystemProperties < AbstractModel
    attribute :interface, :readonly => true, :property => false
    attribute :min_guest_ram, :readonly => true
    attribute :max_guest_ram, :readonly => true
    attribute :min_guest_vram, :readonly => true
    attribute :max_guest_vram, :readonly => true
    attribute :min_guest_cpu_count, :readonly => true
    attribute :max_guest_cpu_count, :readonly => true
    attribute :info_vd_size, :readonly => true
    attribute :network_adapter_count, :readonly => true
    attribute :serial_port_count, :readonly => true
    attribute :parallel_port_count, :readonly => true
    attribute :max_boot_position, :readonly => true
    attribute :default_machine_folder
    attribute :medium_formats, :readonly => true
    attribute :default_hard_disk_format
    attribute :vrde_auth_library
    attribute :web_service_auth_library
    attribute :log_history_count
    attribute :default_audio_driver, :readonly => true

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
    def initialize(isysprop)
      initialize_attributes(isysprop)
    end

    # Initializes the attributes of an existing shared folder.
    def initialize_attributes(isysprop)
      # Save the interface to an attribute
      write_attribute(:interface, isysprop)

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
