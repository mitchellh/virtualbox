module VirtualBox
  # Represents a network interface on the host. There are generally
  # two types of network interfaces wihch exist on the host: bridged
  # and host-only. This class represents both.
  class HostNetworkInterface < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :name, :readonly => true
    attribute :uuid, :readonly => true, :property => :id
    attribute :network_name, :readonly => true
    attribute :dhcp_enabled, :readonly => true
    attribute :ip_address, :readonly => true
    attribute :network_mask, :readonly => true
    attribute :ip_v6_supported, :readonly => true
    attribute :ip_v6_address, :readonly => true
    attribute :ip_v6_network_mask_prefix_length, :readonly => true
    attribute :hardware_address, :readonly => true
    attribute :medium_type, :readonly => true
    attribute :status, :readonly => true
    attribute :interface_type, :readonly => true

    class << self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<HostNetworkInterface>]
      def populate_relationship(caller, ihost)
        relation = Proxies::Collection.new(caller)

        ihost.network_interfaces.each do |inet|
          relation << new(caller, inet)
        end

        relation
      end
    end

    def initialize(parent, inet)
      populate_attributes({:parent => parent}, :ignore_relationships => true)
      initialize_attributes(inet)
    end

    def initialize_attributes(inet)
      load_interface_attributes(inet)
    end
  end
end
