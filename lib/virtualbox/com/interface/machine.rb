module VirtualBox
  module COM
    module Interface
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
        property :memory_size, T_UINT32
        property :memory_balloon_size, T_UINT32
        property :statistics_update_interval, T_UINT32
        property :vram_size, T_UINT32
        property :accelerate_3d_enabled, T_BOOL
        property :accelerate_2d_video_enabled, T_BOOL
        property :monitor_count, T_UINT32
        property :bios_settings, :BIOSSettings, :readonly => true
        property :firmware_type, :FirmwareType
        property :snapshot_folder, WSTRING
        property :vrdp_server, :VRDPServer, :readonly => true
        property :medium_attachments, [:MediumAttachment], :readonly => true
        property :usb_controller, :USBController, :readonly => true
        property :audio_adapter, :AudioAdapter, :readonly => true
        property :storage_controllers, [:StorageController], :readonly => true
        property :settings_file_path, WSTRING, :readonly => true
        property :settings_modified, T_BOOL, :readonly => true
        property :session_state, :SessionState, :readonly => true
        property :session_type, WSTRING, :readonly => true
        property :session_pid, T_UINT32, :readonly => true
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

        function :set_boot_order, nil, [T_UINT32, :DeviceType]
        function :get_boot_order, :DeviceType, [T_UINT32]
        function :attach_device, nil, [WSTRING, T_INT32, T_INT32, :DeviceType, WSTRING]
        function :detach_device, nil, [WSTRING, T_INT32, T_INT32]
        function :passthrough_device, nil, [WSTRING, T_INT32, T_INT32, T_BOOL]
        function :mount_medium, nil, [WSTRING, T_INT32, T_INT32, WSTRING, T_BOOL]
        function :get_medium, :Medium, [WSTRING, T_INT32, T_INT32]
        function :get_medium_attachments_of_controller, [:MediumAttachments], [WSTRING]
        function :get_medium_attachment, :MediumAttachment, [WSTRING, T_INT32, T_INT32]
        function :get_network_adapter, :NetworkAdapter, [T_UINT32]
        function :add_storage_controller, :StorageController, [WSTRING, T_UINT32]
        function :get_storage_controller_by_name, :StorageController, [WSTRING]
        function :get_storage_controller_by_instance, :StorageController, [T_UINT32]
        function :remove_storage_controller, nil, [WSTRING]
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
        function :delete_settings, nil, []
        function :export, :VirtualSystemDescription, [:Appliance]
        function :get_snapshot, :Snapshot, [WSTRING]
        function :find_snapshot, :Snapshot, [WSTRING]
        function :set_current_snapshot, nil, [WSTRING]
        function :create_shared_folder, nil, [WSTRING, WSTRING, T_BOOL]
        function :remove_shared_folder, nil, [WSTRING]
        function :can_show_console_window, T_BOOL, []
        function :show_console_window, T_UINT64, []
        function :get_guest_property, nil, [WSTRING, [:out, WSTRING], [:out, T_UINT64], [:out, WSTRING]]
        function :get_guest_property_value, WSTRING, [WSTRING]
        function :get_guest_property_timestamp, T_UINT64, [WSTRING]
        function :set_guest_property, nil, [WSTRING, WSTRING, WSTRING]
        function :set_guest_propetty_value, nil, [WSTRING, WSTRING]
        function :enumerate_guest_properties, nil, [WSTRING, [:out, [WSTRING]], [:out, [WSTRING]], [:out, [T_UINT64]], [:out, [WSTRING]]]
        function :query_saved_thumbnail_size, nil, [[:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32]]
        function :read_saved_thumbnail_to_array, [T_UINT8], [T_BOOL, [:out, T_UINT32], [:out, T_UINT32]]
        function :query_saved_screenshot_png_size, nil, [[:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32]]
        function :read_saved_png_screenshot_to_array, [T_UINT8], [[:out, T_UINT32], [:out, T_UINT32]]
      end
    end
  end
end
