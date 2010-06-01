module VirtualBox
  class DHCPServer < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :parent_collection, :readonly => true, :property => false
    attribute :interface, :readonly => true, :property => false
    attribute :enabled
    attribute :ip_address
    attribute :network_mask
    attribute :network_name, :readonly => true
    attribute :lower_ip
    attribute :upper_ip

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

    def save
      configs = [:ip_address, :network_mask, :lower_ip, :upper_ip]
      configs_changed = configs.map { |key| changed?(key) }.any? { |i| i }

      if configs_changed
        interface.set_configuration(ip_address, network_mask, lower_ip, upper_ip)

        # Clear the dirtiness so that the abstract model doesn't try
        # to save the attributes
        configs.each do |key|
          clear_dirty!(key)
        end
      end

      save_changed_interface_attributes(interface)
    end

    # Removes the DHCP server.
    def destroy
      parent.lib.virtualbox.remove_dhcp_server(interface)
      parent_collection.delete(self, true)
      true
    end
  end
end
