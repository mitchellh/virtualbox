module VirtualBox
  class AudioAdapter < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :enabled, :boolean => true
    attribute :audio_controller
    attribute :audio_driver

    class <<self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [BIOS]
      def populate_relationship(caller, imachine)
        data = new(caller, imachine.audio_adapter)
      end

      # Saves the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, instance)
        instance.save
      end
    end

    def initialize(parent, iaudio)
      write_attribute(:parent, parent)

      # Load the attributes and mark the whole thing as existing
      load_interface_attributes(iaudio)
      clear_dirty!
      existing_record!
    end

    def save
      parent.with_open_session do |session|
        machine = session.machine

        # Save them
        save_changed_interface_attributes(machine.audio_adapter)
      end
    end
  end
end