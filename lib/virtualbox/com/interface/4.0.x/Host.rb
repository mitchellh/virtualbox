module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class Host < AbstractInterface
          IID_STR = "e380cbfc-ae65-4fa6-899e-45ded6b3132a"

          property :dvd_drives, [:Medium], :readonly => true
          property :floppy_drives, [:Medium], :readonly => true
          property :usb_devices, [:HostUSBDevice], :readonly => true
          property :usb_device_filters, [:HostUSBDeviceFilter], :readonly => true
          property :network_interfaces, [:HostNetworkInterface], :readonly => true
          property :processor_count, T_ULONG, :readonly => true
          property :processor_online_count, T_ULONG, :readonly => true
          property :processor_core_count, T_ULONG, :readonly => true
          property :memory_size, T_ULONG, :readonly => true
          property :memory_available, T_ULONG, :readonly => true
          property :operating_system, WSTRING, :readonly => true
          property :os_version, WSTRING, :readonly => true
          property :utc_time, T_INT64, :readonly => true
          property :acceleration_3d_available, T_BOOL, :readonly => true

          function :get_processor_speed, T_ULONG, [T_UINT32]
          function :get_processor_feature, T_BOOL, [T_UINT32] # TODO ENUM
          function :get_processor_description, WSTRING, [T_UINT32]
          function :get_processor_cpu_id_leaf, nil, [T_UINT32, T_UINT32, T_UINT32, [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32]]
          function :create_host_only_network_interface, :Progress, [[:out, :HostNetworkInterface]]
          function :remove_host_only_network_interface, :Progress, [WSTRING]
          function :create_usb_device_filter, :HostUSBDeviceFilter, [WSTRING]
          function :insert_usb_device_filter, nil, [T_UINT32, :HostUSBDeviceFilter]
          function :remove_usb_device_filter, nil, [T_UINT32]
          function :find_host_dvd_drive, :Medium, [WSTRING]
          function :find_host_floppy_drive, :Medium, [WSTRING]
          function :find_host_network_interface_by_name, :HostNetworkInterface, [WSTRING]
          function :find_host_network_interface_by_id, :HostNetworkInterface, [WSTRING]
          function :find_host_network_interfaces_of_type, [:HostNetworkInterface], [:HostNetworkInterfaceType]
          function :find_usb_device_by_id, :HostUSBDevice, [WSTRING]
          function :find_usb_device_by_address, :HostUSBDevice, [WSTRING]
        end
      end
    end
  end
end
