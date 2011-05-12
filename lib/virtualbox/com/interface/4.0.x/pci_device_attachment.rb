module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class PciDeviceAttachment < AbstractInterface
          IID_STR = "91F33D6F-E621-4F70-A77E-15F0E3C714D5"

          property :name, WSTRING, :readonly => true
          property :is_physical_device, T_BOOL, :readonly => true
          property :host_address, T_UINT32, :readonly => true
          property :guest_address, T_UINT32, :readonly => true
        end
      end
    end
  end
end
