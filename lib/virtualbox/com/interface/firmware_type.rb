module VirtualBox
  module COM
    module Interface
      class FirmwareType < AbstractEnum
        map [:bios, :efi, :efi32, :efi64, :efidual]
      end
    end
  end
end