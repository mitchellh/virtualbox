module VirtualBox
  # Represents a NAT engine for a given {NetworkAdapter}. This data is
  # available through the `nat_driver` relationship on
  # {NetworkAdapter} only if the adapter is a NAT adapter.
  class NATEngine < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :network
    attribute :tftp_prefix
    attribute :tftp_boot_file
    attribute :tftp_next_server
    attribute :alias_mode
    attribute :dns_pass_domain
    attribute :dns_proxy
    attribute :dns_use_host_resolver
    attribute :interface, :readonly => true, :property => false
    relationship :forwarded_ports, :NATForwardedPort

    class << self
      # Populates the NAT engine for anything which is related to it.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [NATEngine]
      def populate_relationship(caller, inat)
        return nil if inat.nil?
        new(caller, inat)
      end

      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, item)
        item.save
      end
    end

    def initialize(caller, inat)
      super()
      initialize_attributes(caller, inat)
    end

    # Initializes the attributes of an existing NAT engine.
    def initialize_attributes(parent, inat)
      write_attribute(:parent, parent)
      write_attribute(:interface, inat)

      # Load the interface attributes associated with this model
      load_interface_attributes(inat)
      populate_relationships(inat)

      # Clear dirty and set as existing
      clear_dirty!
      existing_record!
    end

    def save
      save_changed_interface_attributes(interface)
      save_relationships
    end
  end
end
