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
  #     port = VirtualBox::NATForwardedPort.new
  #     port.name = "apache" # This can be anything
  #     port.guestport = 80
  #     port.hostport = 8080
  #     vm.network_adapters[0].nat_driver.forwarded_ports << port
  #     port.save # Or vm.save
  #
  # # Modifying an Existing Forwarded Port
  #
  # This is assuming that `vm` is a local variable storing a {VM} object
  # which has already been found.
  #
  #     ports = vm.network_adapters[0].nat_driver.forwarded_ports
  #     ports.first.hostport = 1919
  #     vm.save
  #
  # # Deleting a Forwarded Port
  #
  # To delete a forwarded port, you simply destroy it like any other model:
  #
  #     ports = vm.network_adapters[0].nat_driver.forwarded_ports
  #     ports.first.destroy
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
  #     attribute :protocol, :default => "TCP"
  #     attribute :guestport
  #     attribute :hostport
  #
  class NATForwardedPort < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :parent_collection, :readonly => true, :property => false
    attribute :name
    attribute :protocol, :default => :tcp
    attribute :guestport
    attribute :hostport

    class << self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<NATForwardedPort>]
      def populate_relationship(caller, interface)
        relation = Proxies::Collection.new(caller)

        interface.redirects.each do |key, value|
          parts = key.split(",")

          port = new({
            :parent => caller,
            :parent_collection => relation,
            :name => parts[0],
            :protocol => COM::Util.versioned_interface(:NATProtocol).index(parts[1]),
            :guestport => parts[5],
            :hostport => parts[3]
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
        data.dup.each do |fp|
          fp.save
        end
      end
    end

    # @param [Hash] data The initial attributes to populate.
    def initialize(data={})
      super()
      populate_attributes(data) if !data.empty?
    end

    # Validates a forwarded port.
    def validate
      super

      validates_presence_of :parent
      validates_presence_of :name
      validates_presence_of :guestport
      validates_presence_of :hostport
    end

    # Saves the forwarded port.
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def save
      return true if !new_record? && !changed?
      raise Exceptions::ValidationFailedException.new(errors) if !valid?
      destroy if !new_record?

      parent.modify_engine do |nat|
        nat.add_redirect(name, protocol, "", hostport, "", guestport)
      end

      clear_dirty!
      existing_record!
      true
    end

    # Destroys the port forwarding mapping.
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def destroy
      return if new_record?
      previous_name = name_changed? ? name_was : name
      parent.interface.remove_redirect(previous_name)
      parent_collection.delete(self, true) if parent_collection
      new_record!
      true
    end

    # Relationship callback when added to a collection. This is automatically
    # called by any relationship collection when this object is added.
    def added_to_relationship(proxy)
      write_attribute(:parent, proxy.parent)
      write_attribute(:parent_collection, proxy)
    end
  end
end
