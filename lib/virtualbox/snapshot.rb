module VirtualBox
  # Represents a virtual machine snapshot.
  class Snapshot < AbstractModel
    attribute :uuid, :readonly => true, :property => :id
    attribute :name
    attribute :description
    attribute :time_stamp, :readonly => true
    attribute :online, :readonly => true, :boolean => true
    attribute :interface, :readonly => true, :property => false
    relationship :machine, :VM, :lazy => true
    # TODO: Children

    class <<self
      # Populates a relationship with another model. Since a snapshot
      # can be in a relationship with multiple items, this method forwards
      # to other methods such as {populate_vm_relationship}.
      #
      # **This method typically won't be used except internally.**
      def populate_relationship(caller, data)
        if data.is_a?(COM::Interface::Machine)
          populate_machine_relationship(caller, data)
        else
          raise Exceptions::Exception.new("Invalid relationship data for Snapshot: #{data}")
        end
      end

      # Populates the VM relationship as the "current snapshot."
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Snapshot]
      def populate_machine_relationship(caller, machine)
        # The current snapshot can and will be nil if there are no snapshots
        # taken. In that case, we just return nil.
        snapshot = machine.current_snapshot
        snapshot ? new(machine.current_snapshot) : nil
      end
    end

    def initialize(snapshot)
      write_attribute(:interface, snapshot)
      initialize_attributes(snapshot)
    end

    def initialize_attributes(snapshot)
      # Load the interface attributes
      load_interface_attributes(snapshot)

      # Setup the relationships
      populate_relationships(snapshot)

      # Clear dirtiness, since this should only be called initially and
      # therefore shouldn't affect dirtiness
      clear_dirty!

      # But this is an existing record
      existing_record!
    end
  end
end