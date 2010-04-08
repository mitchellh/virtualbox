module VirtualBox
  module COM
    module Interface
      class StorageControllerType < AbstractEnum
        map [:null, :lsi_logic, :bus_logic, :intel_ahci, :piix3, :piix4, :ich6, :i82078]
      end
    end
  end
end