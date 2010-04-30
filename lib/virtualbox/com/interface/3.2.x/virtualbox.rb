module VirtualBox
  module COM
    module Interface
      module Version_3_2_X
        class VirtualBox < AbstractInterface
          IID_STR = "3f36e024-7fed-4f20-a02c-9158a82b44e6"

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

          function :create_machine, :Machine, [WSTRING, WSTRING, WSTRING, WSTRING]
          function :create_legacy_machine, :Machine, [WSTRING, WSTRING, WSTRING, WSTRING]
          function :open_machine, :Machine, [WSTRING]
          function :register_machine, :Machine, [:Machine]
          function :get_machine, :Machine, [WSTRING]
          function :find_machine, :Machine, [WSTRING]
          function :unregister_machine, :Machine, [WSTRING]
          function :create_appliance, :Appliance, []
          function :create_hard_disk, :Medium, [WSTRING, WSTRING]
          function :open_hard_disk, :Medium, [WSTRING, T_UINT32, T_BOOL, WSTRING, T_BOOL, WSTRING]
          function :get_hard_disk, :Medium, [WSTRING]
          function :find_hard_disk, :Medium, [WSTRING]
          function :open_dvd_image, :Medium, [WSTRING, WSTRING]
          function :get_dvd_image, :Medium, [WSTRING]
          function :find_dvd_image, :Medium, [WSTRING]
          function :open_floppy_image, :Medium, [WSTRING, WSTRING]
          function :get_floppy_image, :Medium, [WSTRING]
          function :find_floppy_image, :Medium, [WSTRING]
          function :get_guest_os_type, :GuestOSType, [WSTRING]
          function :create_shared_folder, nil, [WSTRING, WSTRING, T_BOOL]
          function :remove_shared_folder, nil, [WSTRING]
          function :get_extra_data_keys, [WSTRING], []
          function :get_extra_data, WSTRING, [WSTRING]
          function :set_extra_data, nil, [WSTRING, WSTRING]
          function :open_session, nil, [:Session, WSTRING]
          function :open_remote_session, :Progress, [:Session, WSTRING, WSTRING, WSTRING]
          function :open_existing_session, nil, [:Session, WSTRING]
        end
      end
    end
  end
end
