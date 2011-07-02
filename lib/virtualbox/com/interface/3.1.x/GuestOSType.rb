module VirtualBox
  module COM
    module Interface
      module Version_3_1_X
        class GuestOSType < AbstractInterface
          IID = "cfe9e64c-4430-435b-9e7c-e3d8e417bd58"

          property :family_id, WSTRING, :readonly => true
          property :family_description, WSTRING, :readonly => true
          property :id, WSTRING, :readonly => true
          property :description, WSTRING, :readonly => true
          property :is_64_bit, T_BOOL, :readonly => true
          property :recommended_io_apic, T_BOOL, :readonly => true
          property :recommended_virt_ex, T_BOOL, :readonly => true
          property :recommended_ram, T_UINT32, :readonly => true
          property :recommended_vram, T_UINT32, :readonly => true
          property :recommended_hdd, T_UINT32, :readonly => true
          property :adapter_type, :NetworkAdapterType, :readonly => true
        end
      end
    end
  end
end