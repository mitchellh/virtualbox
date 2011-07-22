module VirtualBox
  # Represents a single NIC (Network Interface Card) of a virtual machine.
  #
  # # Create a Network Adapter
  #
  # There is no need to have the ability to create a network adapter,
  # since when creating a VM from scratch, all eight network adapter
  # slots are created, but set to `attachment_type` `nil`. Simply
  # modify the adapter you're interested in and save.
  #
  #
  # # Editing a Network Adapter
  #
  # Network adapters can be modified directly in their relationship to other
  # virtual machines. When {VM#save} is called, it will also save any
  # changes to its relationships. Additionally, you may call {#save}
  # on the relationship itself.
  #
  #     vm = VirtualBox::VM.find("foo")
  #     vm.network_adapters[0].macaddress = @new_mac_address
  #     vm.save
  #
  # # Destroying a Network Adapter
  #
  # Network adapters can not actually be "destroyed" but can be
  # removed by setting the `attachment_type` to `nil` and saving.
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
  #     attribute :slot, :readonly => true
  #     attribute :enabled, :boolean => true
  #     attribute :attachment_type
  #     attribute :adapter_type
  #     attribute :mac_address
  #     attribute :cable_connected, :boolean => true
  #     attribute :nat_network
  #     attribute :internal_network
  #     attribute :host_only_interface
  #     attribute :interface, :readonly => true, :property => false
  #
  class NetworkAdapter < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :slot, :readonly => true
    attribute :enabled, :boolean => true
    attribute :attachment_type
    attribute :adapter_type
    attribute :mac_address
    attribute :cable_connected, :boolean => true
    attribute :nat_network
    attribute :internal_network
    attribute :host_only_interface
    attribute :bridged_interface
    attribute :interface, :readonly => true, :property => false
    relationship :nat_driver, :NATEngine, :lazy => true

    class << self
      # Populates the nic relationship for anything which is related to it.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<Nic>]
      def populate_relationship(caller, imachine)
        relation = Proxies::Collection.new(caller)

        # Get the count of network adapters for a chipset of the type
        # that is our machine.
        count = imachine.parent.system_properties.get_max_network_adapters(imachine.chipset_type)

        count.times do |i|
          relation << new(caller, imachine.get_network_adapter(i))
        end

        relation
      end

      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, items)
        items.each do |item|
          item.save
        end
      end
    end

    def initialize(caller, inetwork)
      super()

      initialize_attributes(caller, inetwork)
    end

    # Initializes the attributes of an existing shared folder.
    def initialize_attributes(parent, inetwork)
      # Set the parent and interface
      write_attribute(:parent, parent)
      write_attribute(:interface, inetwork)

      # Load the interface attributes
      load_interface_attributes(inetwork)

      # Clear dirtiness, since this should only be called initially and
      # therefore shouldn't affect dirtiness
      clear_dirty!

      # But this is an existing record
      existing_record!
    end

    def load_relationship(name)
      # Lazy load the NAT driver. This is only supported by VirtualBox
      # 3.2 and higher. This restriction is checked when the
      # relationship attribute is accessed.
      populate_relationship(:nat_driver, interface.nat_driver)
    end

    # Gets the host interface object associated with the class if it
    # exists.
    def host_interface_object
      VirtualBox::Global.global.host.network_interfaces.find do |ni|
        ni.name == host_only_interface
      end
    end

    # Gets the bridged interface object associated with the class if it
    # exists.
    def bridged_interface_object
      VirtualBox::Global.global.host.network_interfaces.find do |ni|
        ni.name == bridged_interface
      end
    end

    # Save a network adapter.
    def save
      modify_adapter do |adapter|
        save_changed_interface_attributes(adapter)
        save_relationships
      end
    end

    # Opens a session, yields the adapter and then saves the machine at
    # the end
    def modify_adapter
      parent_machine.with_open_session do |session|
        machine = session.machine
        yield machine.get_network_adapter(slot)
      end
    end
  end
end
