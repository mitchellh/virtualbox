module VirtualBox
  # Represents a USB device filter within VirtualBox. This class
  # is a relationship to {USBController} objects.
  class USBDeviceFilter < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :interface, :readonly => true, :property => false
    attribute :name
    attribute :active, :boolean => true
    attribute :vendor_id
    attribute :product_id
    attribute :revision
    attribute :manufacturer
    attribute :product
    attribute :serial_number
    attribute :port
    attribute :remote
    attribute :masked_interfaces

    class << self
      # Populates the USB controller relationship for anything
      # which is related to it.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [USBDeviceFilter]
      def populate_relationship(caller, usbcontroller)
        result = Proxies::Collection.new(caller)

        usbcontroller.device_filters.each do |filter|
          result << new(filter)
        end

        result
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

    # Saves the USB device.
    def save
      parent.with_open_session do |session|
        # TODO: save_changed_interface_attributes(session.machine.usb_controller)
      end
    end
  end
end
