module VirtualBox
  # Represents the media registry within the global VirtualBox configuration.
  class Media < AbstractModel
    attribute :parent, :readonly => true
    relationship :hard_drives, HardDrive

    class <<self
      def populate_relationship(caller, data)
        new(caller, data)
      end
    end

    def initialize(parent, document)
      populate_attributes({ :parent => parent }, :ignore_relationships => true)
      populate_relationships(document)
    end
  end
end