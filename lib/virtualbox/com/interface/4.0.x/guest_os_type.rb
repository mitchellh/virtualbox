module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
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
          property :recommended_pae, T_BOOL, :readonly => true
          property :recommended_dvd_storage_controller, T_UINT32, :readonly => true
          property :recommended_dvd_storage_bus, T_UINT32, :readonly => true
          property :recommended_hd_storage_controller, T_UINT32, :readonly => true
          property :recommended_hd_storage_bus, T_UINT32, :readonly => true
          property :recommended_firmware, T_UINT32, :readonly => true
          property :recommended_usb_hid, T_BOOL, :readonly => true
          property :recommended_hpet, T_BOOL, :readonly => true
          property :recommended_usb_tablet, T_BOOL, :readonly => true
          property :recommended_rtc_use_utc, T_BOOL, :readonly => true
        end
      end
    end
  end
end