module VirtualBox
  # Represents a single USB device of a virtual machine.
  #
  # **Currently, new USB devices can't be created, so the only way to get this
  # object is through a {VM}'s `usbs` relationship.**
  #
  # # Attributes
  #
  # Properties of the model are exposed using standard ruby instance
  # methods which are generated on the fly. Because of this, they are not listed
  # below as available instance methods.
  #
  # These attributes can be accessed and modified via standard ruby-style
  # `instance.attribute` and `instance.attribute=` methods. The attributes are
  # listed below. If you aren't sure what this means or you can't understand
  # why the below is listed, please read {Attributable}.
  #
  #     attribute :parent, :readonly => :readonly
  #     attribute :name
  #     attribute :active
  #     attribute :manufacturer
  #     attribute :product
  #     attribute :remote
  #
  class USB < AbstractModel
    attribute :parent, :readonly => :readonly
    attribute :name
    attribute :active
    attribute :manufacturer
    attribute :product
    attribute :remote

    class <<self
      # Populates the usb device relationship for anything which is related to it.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<USB>]
      def populate_relationship(caller, doc)
        relation = Proxies::Collection.new(caller)

        doc.css("Hardware USBController DeviceFilter").each do |device|
          relation << new(caller, device)
        end

        relation
      end
    end

    # Since there is currently no way to create a _new_ usb device, this is
    # only used internally. Developers should NOT try to initialize their
    # own usb device objects.
    def initialize(caller, data)
      super()

      # Set the parent
      write_attribute(:parent, caller)

      # Convert each attribute value to a string
      attrs = {}

      data.attributes.each do |key, value|
        attrs[key.to_sym] = value.to_s
      end

      populate_attributes(attrs)

      # Clear dirtiness
      clear_dirty!
    end
  end
end