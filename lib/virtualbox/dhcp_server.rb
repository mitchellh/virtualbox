module VirtualBox
  class DHCPServer < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :parent_collection, :readonly => true, :property => false
    attribute :interface, :readonly => true, :property => false
    attribute :enabled
    attribute :ip_address, :readonly => true
    attribute :network_mask, :readonly => true
    attribute :network_name, :readonly => true
    attribute :lower_ip, :readonly => true
    attribute :upper_ip, :readonly => true

    class << self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<DHCPServer>]
      def populate_relationship(caller, servers)
        relation = Proxies::Collection.new(caller, self)

        servers.each do |interface|
          relation << new(interface)
        end

        relation
      end
    end

    def initialize(raw)
      initialize_attributes(raw)
    end

    def initialize_attributes(raw)
      write_attribute(:interface, raw)

      load_interface_attributes(interface)
      existing_record!
    end

    def added_to_relationship(proxy)
      write_attribute(:parent, proxy.parent)
      write_attribute(:parent_collection, proxy)
    end
  end
end
