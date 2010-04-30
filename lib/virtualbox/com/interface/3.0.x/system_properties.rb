module VirtualBox
  module COM
    module Interface
      module Version_3_0_X
        class SystemProperties < AbstractInterface
          IID = "8030645c-8fef-4320-bb7b-c829f00069dc"

          property :min_guest_ram, T_UINT32, :readonly => true
          property :max_guest_ram, T_UINT32, :readonly => true
          property :min_guest_vram, T_UINT32, :readonly => true
          property :max_guest_vram, T_UINT32, :readonly => true
          property :min_guest_cpu_count, T_UINT32, :readonly => true
          property :max_guest_cpu_count, T_UINT32, :readonly => true
          property :max_vdi_size, T_UINT64, :readonly => true
          property :network_adapter_count, T_UINT32, :readonly => true
          property :serial_port_count, T_UINT32, :readonly => true
          property :parallel_port_count, T_UINT32, :readonly => true
          property :max_boot_position, T_UINT32, :readonly => true
          property :default_machine_folder, WSTRING
          property :default_hard_disk_folder, WSTRING
          property :medium_formats, [:MediumFormat], :readonly => true
          property :default_hard_disk_format, WSTRING
          property :remote_display_auth_library, WSTRING
          property :web_service_auth_library, WSTRING
          property :log_history_count, T_UINT32
          property :default_audio_driver, :AudioDriverType, :readonly => true

          function :get_max_devices_per_port_for_storage_bus, T_UINT32, [:StorageBus]
          function :get_min_port_count_for_storage_bus, T_UINT32, [:StorageBus]
          function :get_max_port_count_for_storage_bus, T_UINT32, [:StorageBus]
          function :get_max_instances_of_storage_bus, T_UINT32, [:StorageBus]
          function :get_device_types_for_storage_bus, [:DeviceType], [:StorageBus]
        end
      end
    end
  end
end