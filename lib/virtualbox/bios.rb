module VirtualBox
  # Represents the BIOS settings of a {VM}.
  class BIOS < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :acpi_enabled
    attribute :io_apic_enabled

    class <<self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [BIOS]
      def populate_relationship(caller, imachine)
        data = new(caller, imachine.bios_settings)
      end

      # Saves the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, instance)
        instance.save
      end
    end

    def initialize(parent, bios_settings)
      write_attribute(:parent, parent)

      # Load the attributes and mark the whole thing as existing
      load_interface_attributes(bios_settings)
      clear_dirty!
      existing_record!
    end

    def save
      parent.with_open_session do |session|
        machine = session.machine

        # Save them
        save_changed_interface_attributes(machine.bios_settings)
      end
    end
  end
end