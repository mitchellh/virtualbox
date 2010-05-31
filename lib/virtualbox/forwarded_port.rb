module VirtualBox
  # When a VM uses NAT as its NIC type, VirtualBox acts like its
  # own private router for all virtual machines. Because of this,
  # the host machine can't access services within the guest machine.
  # To get around this, NAT supports port forwarding, which allows the
  # guest machine services to be forwarded to some port on the host
  # machine. Port forwarding is done completely through {ExtraData}, but
  # is a complicated enough procedure that this class was made to
  # faciliate it.
  #
  # **Note:** After changing any forwarded ports, the entire VirtualBox
  # process must be restarted completely for them to take effect. When
  # working with the ruby library, this isn't so much of an issue, but
  # if you have any VMs running, they must all be shut down and restarted.
  #
  # # Adding a new Forwarded Port
  #
  # Since forwarded ports rely on being part of a {VM}, we're going to
  # assume that `vm` points to a {VM} which has already been found.
  #
  #     port = VirtualBox::ForwardedPort.new
  #     port.name = "apache" # This can be anything
  #     port.guestport = 80
  #     port.hostport = 8080
  #     vm.forwarded_ports << port
  #     port.save # Or vm.save
  #
  # # Modifying an Existing Forwarded Port
  #
  # This is assuming that `vm` is a local variable storing a {VM} object
  # which has already been found.
  #
  #     vm.forwarded_ports.first.hostport = 1919
  #     vm.save
  #
  # # Deleting a Forwarded Port
  #
  # To delete a forwarded port, you simply destroy it like any other model:
  #
  #     vm.forwarded_ports.first.destroy
  #
  # # Attributes and Relationships
  #
  # Properties of the model are exposed using standard ruby instance
  # methods which are generated on the fly. Because of this, they are not listed
  # below as available instance methods.
  #
  # These attributes can be accessed and modified via standard ruby-style
  # `instance.attribute` and `instance.attribute=` methods. The attributes are
  # listed below.
  #
  # Relationships are also accessed like attributes but can't be set. Instead,
  # they are typically references to other objects such as an {AttachedDevice} which
  # in turn have their own attributes which can be modified.
  #
  # ## Attributes
  #
  # This is copied directly from the class header, but lists all available
  # attributes. If you don't understand what this means, read {Attributable}.
  #
  #     attribute :parent, :readonly => true
  #     attribute :name
  #     attribute :instance, :default => "0"
  #     attribute :device, :default => "pcnet"
  #     attribute :protocol, :default => "TCP"
  #     attribute :guestport
  #     attribute :hostport
  #
  class ForwardedPort < AbstractModel
    attribute :parent, :readonly => true
    attribute :name
    attribute :instance, :default => "0"
    attribute :device, :default => "pcnet"
    attribute :protocol, :default => "TCP"
    attribute :guestport
    attribute :hostport

    class << self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<ForwardedPort>]
      def populate_relationship(caller, data)
        relation = Proxies::Collection.new(caller)

        caller.extra_data.each do |key, value|
          next unless key =~ /^(VBoxInternal\/Devices\/(.+?)\/(.+?)\/LUN#0\/Config\/(.+?)\/)Protocol$/i

          port = new({
            :parent => caller,
            :name => $4.to_s,
            :instance => $3.to_s,
            :device => $2.to_s,
            :protocol => value,
            :guestport => caller.extra_data["#{$1.to_s}GuestPort"],
            :hostport => caller.extra_data["#{$1.to_s}HostPort"]
          })

          port.existing_record!

          relation.push(port)
        end

        relation
      end

      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, data)
        data.each do |fp|
          fp.save
        end
      end
    end

    # @param [Hash] data The initial attributes to populate.
    def initialize(data={})
      super()
      populate_attributes(data)
    end

    # Validates a forwarded port.
    def validate
      super

      validates_presence_of :parent
      validates_presence_of :name
      validates_presence_of :guestport
      validates_presence_of :hostport
    end

    # Retrieves the device for the forwarded port. This tries to "do the
    # right thing" depending on the first NIC of the VM parent by either
    # setting the forwarded port type to "pcnet" or "e1000." If the device
    # was already set manually, this method will simply return that value
    # instead.
    #
    # @return [String] Device type for the forwarded port
    def device
      # Return the current or default value if it is:
      #  * an existing record, since it was already mucked with, no need to
      #    modify it again
      #  * device setting changed, since we should return what the user set
      #    it to
      #  * If the parent is nil, since we can't infer the type without a parent
      return read_attribute(:device) if !new_record? || device_changed? || parent.nil?

      device_map = {
        :Am79C970A => "pcnet",
        :Am79C973 => "pcnet",
        :I82540EM => "e1000",
        :I82543GC => "e1000",
        :I82545EM => "e1000"
      }

      return device_map[parent.network_adapters[0].adapter_type]
    end

    # Saves the forwarded port.
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def save
      return true if !new_record? && !changed?

      raise Exceptions::ValidationFailedException.new(errors) if !valid?

      destroy if name_changed?

      parent.extra_data["#{key_prefix}Protocol"] = protocol
      parent.extra_data["#{key_prefix}GuestPort"] = guestport
      parent.extra_data["#{key_prefix}HostPort"] = hostport
      result = parent.extra_data.save

      clear_dirty!
      existing_record!

      result
    end

    # Destroys the port forwarding mapping.
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def destroy
      results = []

      if !new_record?
        results << parent.extra_data.delete("#{key_prefix(true)}Protocol")
        results << parent.extra_data.delete("#{key_prefix(true)}GuestPort")
        results << parent.extra_data.delete("#{key_prefix(true)}HostPort")

        new_record!
      end

      results.empty? || results.all? { |o| o == true }
    end

    # Relationship callback when added to a collection. This is automatically
    # called by any relationship collection when this object is added.
    def added_to_relationship(parent)
      write_attribute(:parent, parent)
    end

    # Returns the prefix to be used for the extra data key. Forwarded ports
    # are created by simply setting {ExtraData} on a {VM}. This class hides most
    # of the inner workings of it, but it requires a common prefix. This method
    # generates that.
    #
    # @return [String]
    def key_prefix(old_name=false)
      name_value = old_name && name_changed? ? name_was : name
      "VBoxInternal\/Devices\/#{device}\/#{instance}\/LUN#0\/Config\/#{name_value}\/"
    end
  end
end
