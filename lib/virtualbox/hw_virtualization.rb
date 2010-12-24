module VirtualBox
  # Represents the HW virtualization properties on a VM.
  class HWVirtualization < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute_scope(:property_getter => Proc.new { |instance, *args| instance.get_property(*args) },
                    :property_setter => Proc.new { |instance, *args| instance.set_property(*args) }) do
      attribute :enabled, :boolean => true
      attribute :exclusive, :boolean => true
      attribute :vpid, :boolean => true
      attribute :nested_paging, :boolean => true
      attribute :force, :boolean => true
    end

    class << self
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

    def get_property(interface, key)
      interface.get_hw_virt_ex_property(key)
    end

    def set_property(interface, key, value)
      interface.set_hw_virt_ex_property(key, value)
    end

    def validate
      super

      validates_inclusion_of :enabled, :exclusive, :vpid, :nested_paging, :in => [true, false]
    end

    def save
      parent.with_open_session do |session|
        machine = session.machine

        # Save them
        save_changed_interface_attributes(machine)
      end
    end
  end
end
