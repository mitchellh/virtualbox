module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class Machine < AbstractInterface
          IID_STR = "99404f50-dd10-40d3-889b-dd2f79f1e95e"

          property :parent, :VirtualBox, :readonly => true
          property :accessible, T_BOOL, :readonly => true
          property :access_error, :VirtualBoxErrorInfo, :readonly => true
          property :name, WSTRING
          property :description, WSTRING
          property :id, WSTRING, :readonly => true
          property :os_type_id, WSTRING
          property :hardware_version, WSTRING
          property :hardware_uuid, WSTRING
          property :cpu_count, T_UINT32
          property :cpu_hot_plug_enabled, T_BOOL
          property :cpu_execution_cap, T_UINT64
          property :memory_size, T_UINT64
          property :memory_balloon_size, T_UINT64
          property :page_fusion_enabled, T_BOOL
          property :vram_size, T_UINT32
          property :accelerate_3d_enabled, T_BOOL
          property :accelerate_2d_video_enabled, T_BOOL
          property :monitor_count, T_UINT64
          property :bios_settings, :BIOSSettings, :readonly => true
          property :firmware_type, :FirmwareType
          property :pointing_hid_type, T_UINT32
          property :keyboard_hid_type, T_UINT32
          property :hpet_enabled, T_BOOL
          property :chipset_type, :ChipsetType
          property :snapshot_folder, WSTRING
          property :vrde_server, :VRDEServer, :readonly => true
          property :medium_attachments, [:MediumAttachment], :readonly => true
          property :usb_controller, :USBController, :readonly => true
          property :audio_adapter, :AudioAdapter, :readonly => true
          property :storage_controllers, [:StorageController], :readonly => true
          property :settings_file_path, WSTRING, :readonly => true
          property :settings_modified, T_BOOL, :readonly => true
          property :session_state, :SessionState, :readonly => true
          property :session_type, WSTRING, :readonly => true
          property :session_pid, T_UINT64, :readonly => true
          property :state, :MachineState, :readonly => true
          property :last_state_change, T_INT64, :readonly => true
          property :state_file_path, WSTRING, :readonly => true
          property :log_folder, WSTRING, :readonly => true
          property :current_snapshot, :Snapshot, :readonly => true
          property :snapshot_count, T_UINT32, :readonly => true
          property :current_state_modified, T_BOOL, :readonly => true
          property :shared_folders, [:SharedFolder], :readonly => true
          property :clipboard_mode, :ClipboardMode
          property :guest_property_notification_patterns, WSTRING
          property :teleporter_enabled, T_BOOL
          property :teleporter_port, T_UINT32
          property :teleporter_address, WSTRING
          property :teleporter_password, WSTRING
          property :fault_tolerance_state, :FaultToleranceState
          property :fault_tolerance_port, T_UINT64
          property :fault_tolerance_address, WSTRING
          property :fault_tolerance_password, WSTRING
          property :fault_tolerance_sync_interval, T_UINT64
          property :rtc_use_utc, T_BOOL
          property :io_cache_enabled, T_BOOL
          property :io_cache_size, T_UINT32
          property :bandwidth_control, :BandwidthControl, :readonly => true
          property :pci_device_assignments, [:PciDeviceAttachment], :readonly => true

          function :lock_machine, nil, [:Session, :LockType]
          function :launch_vm_process, :Progress, [:Session, WSTRING, WSTRING]
          function :set_boot_order, nil, [T_UINT32, :DeviceType]
          function :get_boot_order, :DeviceType, [T_UINT64]
          function :attach_device, nil, [WSTRING, T_INT32, T_INT32, :DeviceType, :Medium]
          function :detach_device, nil, [WSTRING, T_INT32, T_INT32]
          function :passthrough_device, nil, [WSTRING, T_INT32, T_INT32, T_BOOL]
          function :set_bandwidth_group_for_device, nil, [WSTRING, T_INT64, T_INT64, :BandwidthGroup]
          function :mount_medium, nil, [WSTRING, T_INT32, T_INT32, :Medium, T_BOOL]
          function :get_medium, :Medium, [WSTRING, T_INT32, T_INT32]
          function :get_medium_attachments_of_controller, [:MediumAttachments], [WSTRING]
          function :get_medium_attachment, :MediumAttachment, [WSTRING, T_INT32, T_INT32]
          function :attach_host_pci_device, nil, [T_INT32, T_INT32, :EventContext, T_BOOL]
          function :detach_host_pci_device, nil, [T_INT32]
          function :get_network_adapter, :NetworkAdapter, [T_UINT32]
          function :add_storage_controller, :StorageController, [WSTRING, :StorageBus]
          function :get_storage_controller_by_name, :StorageController, [WSTRING]
          function :get_storage_controller_by_instance, :StorageController, [T_UINT32]
          function :remove_storage_controller, nil, [WSTRING]
          function :set_storage_controller_bootable, nil, [WSTRING, T_BOOL]
          function :get_serial_port, :SerialPort, [T_UINT32]
          function :get_parallel_port, :ParallelPort, [T_UINT32]
          function :get_extra_data_keys, [WSTRING], []
          function :get_extra_data, WSTRING, [WSTRING]
          function :set_extra_data, nil, [WSTRING, WSTRING]
          function :get_cpu_property, T_BOOL, [:CpuPropertyType]
          function :set_cpu_property, nil, [:CpuPropertyType, T_BOOL]
          function :get_cpu_id_leaf, nil, [T_UINT32, [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32]]
          function :set_cpu_id_leaf, nil, [T_UINT32, T_UINT32, T_UINT32, T_UINT32, T_UINT32]
          function :remove_cpu_id_leaf, nil, [T_UINT32]
          function :remove_all_cpu_id_leafs, nil, []
          function :get_hw_virt_ex_property, T_BOOL, [:HWVirtExPropertyType]
          function :set_hw_virt_ex_property, nil, [:HWVirtExPropertyType, T_BOOL]
          function :save_settings, nil, []
          function :discard_settings, nil, []
          function :unregister, [:Medium], [:CleanupMode]
          function :delete, :Progress, [[:Medium]]
          function :export, :VirtualSystemDescription, [:Appliance, WSTRING]
          function :find_snapshot, :Snapshot, [WSTRING]
          function :create_shared_folder, nil, [WSTRING, WSTRING, T_BOOL, T_BOOL]
          function :remove_shared_folder, nil, [WSTRING]
          function :can_show_console_window, T_BOOL, []
          function :show_console_window, T_UINT64, []
          function :get_guest_property, nil, [WSTRING, [:out, WSTRING], [:out, T_UINT64], [:out, WSTRING]]
          function :get_guest_property_value, WSTRING, [WSTRING]
          function :get_guest_property_timestamp, T_UINT64, [WSTRING]
          function :set_guest_property, nil, [WSTRING, WSTRING, WSTRING]
          function :set_guest_propetty_value, nil, [WSTRING, WSTRING]
          function :enumerate_guest_properties, nil, [WSTRING, [:out, [WSTRING]], [:out, [WSTRING]], [:out, [T_UINT64]], [:out, [WSTRING]]]
          function :query_saved_guest_size, nil, [T_UINT64, [:out, T_UINT64], [:out, T_UINT64]]
          function :query_saved_thumbnail_size, nil, [T_UINT32, [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32]]
          function :read_saved_thumbnail_to_array, [T_UINT8], [T_UINT32, T_BOOL, [:out, T_UINT32], [:out, T_UINT32]]
          function :query_saved_screenshot_png_size, nil, [T_UINT32, [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32]]
          function :read_saved_png_screenshot_to_array, [T_UINT8], [T_UINT32, [:out, T_UINT32], [:out, T_UINT32]]
          function :hot_plug_cpu, nil, [T_UINT32]
          function :hot_unplug_cpu, nil, [T_UINT32]
          function :get_cpu_status, T_BOOL, [T_UINT32]
          function :query_log_filename, WSTRING, [T_UINT32]
          function :read_log, [T_UINT8], [T_UINT32, T_UINT64, T_UINT64]
        end
      end
    end
  end
end
