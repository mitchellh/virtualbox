module VirtualBox
  module COM
    module Interface
      class StorageBus < AbstractEnum
        map [:null, :ide, :sata, :scsi, :floppy]
      end
    end
  end
end