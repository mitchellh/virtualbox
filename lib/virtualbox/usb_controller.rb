module VirtualBox
  # Represents a USB controller within VirtualBox. This class is a relationship
  # to {VM} objects.
  class USBController < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :interface, :readonly => true, :property => false
    attribute :enabled
    attribute :enabled_ehci
    attribute :usb_standard, :readonly => true

    class <<self
      # Populates the USB controller relationship for anything
      # which is related to it.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [USBController]
      def populate_relationship(caller, machine)
        new(caller, machine.usb_controller)
      end

      # Saves the relationship. This simply calls {#save} on the
      # relationship object.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, item)
        item.save
      end
    end

    def initialize(parent, iusb)
      initialize_attributes(parent, iusb)
    end

    def initialize_attributes(parent, iusb)
      # Write the parent and interface attributes
      write_attribute(:parent, parent)
      write_attribute(:interface, iusb)

      # Load the interface attributes
      load_interface_attributes(interface)

      # Clear dirty and mark as existing
      clear_dirty!
      existing_record!
    end

    # Saves the USB controller.
    def save
      parent.with_open_session do |session|
        save_changed_interface_attributes(session.machine.usb_controller)
      end
    end
  end
end