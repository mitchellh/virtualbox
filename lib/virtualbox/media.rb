module VirtualBox
  # Represents the media registry within the global VirtualBox configuration.
  class Media < AbstractModel
    attribute :parent, :readonly => true
    relationship :hard_drives, :HardDrive
    relationship :dvds, :DVD

    class << self
      def populate_relationship(caller, lib)
        new(caller, lib)
      end
    end

    def initialize(parent, lib)
      populate_attributes({ :parent => parent }, :ignore_relationships => true)
      populate_relationship(:hard_drives, lib.virtualbox.hard_disks)
      populate_relationship(:dvds, lib.virtualbox.dvd_images)
    end
  end
end
