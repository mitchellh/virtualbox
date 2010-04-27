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
    relationship :children, :Snapshot, :lazy => true

    class <<self
      # Populates a relationship with another model. Since a snapshot
      # can be in a relationship with multiple items, this method forwards
      # to other methods such as {populate_vm_relationship}.
      #
      # **This method typically won't be used except internally.**
      def populate_relationship(caller, data)
        if data.is_a?(COM::Interface::Machine)
          populate_machine_relationship(caller, data)
        elsif data.is_a?(Array)
          populate_children_relationship(caller, data)
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

      # Populates the snapshot child tree relationship.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<Snapshot>]
      def populate_children_relationship(caller, snapshots)
        result = Proxies::Collection.new(caller)

        snapshots.each do |snapshot|
          result << new(snapshot)
        end

        result
      end
    end

    # Initializes a new snapshot. This should never be called on its own.
    # Snapshots should be accessed beginning with the `current_snapshot` on
    # a VM, and can be further accessed by traversing the parent/child tree
    # of the snapshot.
    def initialize(snapshot)
      write_attribute(:interface, snapshot)
      initialize_attributes(snapshot)
    end

    def initialize_attributes(snapshot)
      # Load the interface attributes
      load_interface_attributes(snapshot)

      # Clear dirtiness, since this should only be called initially and
      # therefore shouldn't affect dirtiness
      clear_dirty!

      # But this is an existing record
      existing_record!
    end

    # Loads the lazy relationships.
    #
    # **This method should only be called internally.**
    def load_relationship(name)
      populate_relationship(:machine, interface.machine)
      populate_relationship(:children, interface.children)
    end
  end
end