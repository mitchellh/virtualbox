module VirtualBox
  # Represents the VRDP Server settings of a {VM}.
  class VRDEServer < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :enabled, :boolean => true
    attribute :auth_type
    attribute :auth_timeout
    attribute :allow_multi_connection, :boolean => true
    attribute :reuse_single_connection, :boolean => true
    attribute :vrde_ext_pack
    attribute :auth_library

    class << self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [VRDEServer]
      def populate_relationship(caller, imachine)
        data = new(caller, imachine.vrde_server)
      end

      # Saves the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, instance)
        instance.save
      end
    end

    def initialize(parent, vrde_settings)
      write_attribute(:parent, parent)

      # Load the attributes and mark the whole thing as existing
      load_interface_attributes(vrde_settings)
      clear_dirty!
      existing_record!
    end

    def validate
      super

      validates_inclusion_of :enabled, :allow_multi_connection, :reuse_single_connection, :in => [true, false]
      validates_inclusion_of :auth_type, :in => COM::Util.versioned_interface(:AuthType).map
      validates_numericality_of :auth_timeout
    end

    def save
      parent.with_open_session do |session|
        machine = session.machine

        # Save them
        save_changed_interface_attributes(machine.vrde_server)
      end
    end
  end
end
