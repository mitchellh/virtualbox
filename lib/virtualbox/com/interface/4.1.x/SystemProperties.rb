module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class SystemProperties < AbstractInterface
          IID = "8030645c-8fef-4320-bb7b-c829f00069dc"

          property :min_guest_ram, T_UINT32, :readonly => true
          property :max_guest_ram, T_UINT32, :readonly => true
          property :min_guest_vram, T_UINT32, :readonly => true
          property :max_guest_vram, T_UINT32, :readonly => true
          property :min_guest_cpu_count, T_UINT32, :readonly => true
          property :max_guest_cpu_count, T_UINT32, :readonly => true
          property :max_guest_monitors, T_UINT32, :readonly => true
          property :info_vd_size, T_INT64, :readonly => true
          property :network_adapter_count, T_UINT32, :readonly => true
          property :serial_port_count, T_UINT32, :readonly => true
          property :parallel_port_count, T_UINT32, :readonly => true
          property :max_boot_position, T_UINT32, :readonly => true
          property :default_machine_folder, WSTRING
          property :medium_formats, [:MediumFormat], :readonly => true
          property :default_hard_disk_format, WSTRING
          property :free_disk_space_warning, T_UINT64
          property :free_disk_space_percent_warning, T_UINT32
          property :free_disk_space_error, T_UINT64
          property :free_disk_space_percent_error, T_UINT64
          property :vrde_auth_library, WSTRING
          property :web_service_auth_library, WSTRING
          property :log_history_count, T_UINT32
          property :default_audio_driver, :AudioDriverType, :readonly => true

          function :get_max_devices_per_port_for_storage_bus, T_UINT32, [:StorageBus]
          function :get_min_port_count_for_storage_bus, T_UINT32, [:StorageBus]
          function :get_max_port_count_for_storage_bus, T_UINT32, [:StorageBus]
          function :get_max_instances_of_storage_bus, T_UINT32, [:StorageBus]
          function :get_device_types_for_storage_bus, [:DeviceType], [:StorageBus]
          function :get_default_io_cache_setting_for_storage_controller, T_BOOL, [:StorageControllerType]
        end
      end
    end
  end
end
