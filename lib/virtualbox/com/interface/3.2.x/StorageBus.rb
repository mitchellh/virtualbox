module VirtualBox
  module COM
    module Interface
      module Version_3_2_X
        class StorageBus < AbstractEnum
          map [:null, :ide, :sata, :scsi, :floppy, :sas]
        end
      end
    end
  end
end