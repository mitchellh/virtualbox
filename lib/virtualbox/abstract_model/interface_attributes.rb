module VirtualBox
  class AbstractModel
    # Module which can be included which defines helper methods to DRY out the
    # code which handles attributes with {VirtualBox::COM} interfaces. This
    # module works _alongside_ the {Attributable} module, so **both are required**.
    module InterfaceAttributes
      # Loads the attributes which have an interface getter and writes
      # their values.
      #
      # @param [VirtualBox::COM::Interface] interface
      def load_interface_attributes(interface)
        self.class.attributes.each do |key, options|
          load_interface_attribute(key, interface)
        end
      end

      # Loads a single interface attribute.
      #
      # @param [Symbol] key The attribute to load
      # @param [VirtualBox::COM::Interface] interface The interface
      def load_interface_attribute(key, interface)
        # Return unless we have a valid interface attribute with a getter
        return unless has_attribute?(key)
        options = self.class.attributes[key.to_sym]
        return if options.has_key?(:property) && !options[:property]
        getter = options[:property] || options[:property_getter] || key.to_sym
        return unless getter

        # Convert the getter to a proc and call it
        getter = spec_to_proc(getter)
        write_attribute(key, getter.call(self, interface, key))
      end

      # Saves all the attributes which have an interface setter.
      def save_interface_attributes(interface)
        self.class.attributes.each do |key, options|
          save_interface_attribute(key, interface)
        end
      end

      # Saves a single interface attribute
      #
      # @param [Symbol] key The attribute to write
      # @param [VirtualBox::COM::Interface] interface The interface
      # @param [Object] value The value to write
      def save_interface_attribute(key, interface)
        # Return unless we have a valid interface attribute with a setter
        return unless has_attribute?(key)
        options = self.class.attributes[key.to_sym]
        return if options[:readonly]
        return if options.has_key?(:property) && !options[:property]

        setter = options[:property] || options[:property_setter] || "#{key}=".to_sym
        return unless setter

        # Convert the setter to a proc and call it
        setter = spec_to_proc(setter)
        setter.call(self, interface, key, read_attribute(key))
      end

      # Converts a getter/setter specification to a Proc which can be called
      # to obtain or set a value. There are multiple ways to specify the getter
      # and/or setter of an interface attribute:
      #
      # ## Symbol
      #
      # A symbol represents a method to call on the interface. An example of the
      # declaration and resulting method call are shown below:
      #
      #     attribute :foo, :property_getter => :get_foo
      #
      # Converts to:
      #
      #     interface.get_foo
      #
      # ## Proc
      #
      # A proc is called with the interface and it is expected to return the value
      # for a getter. For a setter, the interface and the value is sent in as
      # parameters to the Proc.
      #
      #     attribute :foo, :property_getter => Proc.new { |i| i.get_foo }
      #
      def spec_to_proc(spec)
        # Return the spec as-is if its a proc
        return spec if spec.is_a?(Proc)

        if spec.is_a?(Symbol)
          # For symbols, wrap up a method send in a Proc and return
          # that
          return Proc.new { |this, m, key, *args| m.send(spec, *args) }
        end
      end
    end
  end
end