module VirtualBox
  # Represents the HW virtualization properties on a VM.
  class HWVirtualization < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :enabled
    attribute :exclusive
    attribute :vpid
    attribute :nested_paging

    class <<self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [HWVirtualization]
      def populate_relationship(caller, imachine)
        data = new(caller, imachine)
      end

      # Saves the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, instance)
        instance.save
      end
    end

    def initialize(parent, imachine)
      write_attribute(:parent, parent)

      # Load the attributes and mark the whole thing as existing
      load_interface_attributes(imachine)
      clear_dirty!
      existing_record!
    end
  end
end