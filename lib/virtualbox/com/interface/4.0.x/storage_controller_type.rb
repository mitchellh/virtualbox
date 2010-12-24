module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class StorageControllerType < AbstractEnum
          map [:null, :lsi_logic, :bus_logic, :intel_ahci, :piix3, :piix4, :ich6, :i82078, :lsi_logic_sas]
        end
      end
    end
  end
end