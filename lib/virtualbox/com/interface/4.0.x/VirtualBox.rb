module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class VirtualBox < AbstractInterface
          IID_STR = "D2DE270C-1D4B-4C9E-843F-BBB9B47269FF"

          property :version, WSTRING, :readonly => true
          property :revision, T_ULONG, :readonly => true
          property :package_type, WSTRING, :readonly => true
          property :home_folder, WSTRING, :readonly => true
          property :settings_file_path, WSTRING, :readonly => true
          property :host, :Host, :readonly => true
          property :system_properties, :SystemProperties, :readonly => true
          property :machines, [:Machine], :readonly => true
          property :hard_disks, [:Medium], :readonly => true
          property :dvd_images, [:Medium], :readonly => true
          property :floppy_images, [:Medium], :readonly => true
          property :progress_operations, [:Progress], :readonly => true
          property :guest_os_types, [:GuestOSType], :readonly => true
          property :shared_folders, [:SharedFolder], :readonly => true
          property :performance_collector, :PerformanceCollector, :readonly => true
          property :dhcp_servers, [:DHCPServer], :readonly => true
          property :event_source, :EventSource, :readonly => true
          property :extension_pack_manager, :ExtPackManager, :readonly => true

          function :compose_machine_filename, WSTRING, [WSTRING, WSTRING]
          function :create_machine, :Machine, [WSTRING, WSTRING, WSTRING, WSTRING, T_BOOL]
          function :open_machine, :Machine, [WSTRING]
          function :register_machine, nil, [:Machine]
          function :find_machine, :Machine, [WSTRING]
          function :create_appliance, :Appliance, []
          function :create_hard_disk, :Medium, [WSTRING, WSTRING]
          function :open_medium, :Medium, [WSTRING, :DeviceType, :AccessMode]
          function :find_medium, :Medium, [WSTRING, :DeviceType]
          function :get_guest_os_type, :GuestOSType, [WSTRING]
          function :create_shared_folder, nil, [WSTRING, WSTRING, T_BOOL, T_BOOL]
          function :remove_shared_folder, nil, [WSTRING]
          function :get_extra_data_keys, [WSTRING], []
          function :get_extra_data, WSTRING, [WSTRING]
          function :set_extra_data, nil, [WSTRING, WSTRING]
          function :create_dhcp_server, :DHCPServer, [WSTRING]
          function :find_dhcp_server_by_network_name, :DHCPServer, [WSTRING]
          function :remove_dhcp_server, nil, [:DHCPServer]
          function :check_firmware_present, T_BOOL, [:FirmwareType, WSTRING, [:out, WSTRING], [:out, WSTRING]]
        end
      end
    end
  end
end
