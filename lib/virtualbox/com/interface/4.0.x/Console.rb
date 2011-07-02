module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class Console < AbstractInterface
          IID = "6375231a-c17c-464b-92cb-ae9e128d71c3"

          property :machine, :Machine, :readonly => true
          property :state, :MachineState, :readonly => true
          property :guest, :Guest, :readonly => true
          property :keyboard, :Keyboard, :readonly => true
          property :mouse, :Mouse, :readonly => true
          property :display, :Display, :readonly => true
          property :debugger, :MachineDebugger, :readonly => true
          property :usb_devices, [:USBDevice], :readonly => true
          property :remote_usb_devices, [:HostUSBDevice], :readonly => true
          property :shared_folders, [:SharedFolder], :readonly => true
          property :vrde_server_info, :VRDEServerInfo, :readonly => true
          property :event_source, :EventSource, :readonly => true
          property :attached_pci_devices, [:PciDeviceAttachment], :readonly => true

          function :power_up, :Progress, []
          function :power_up_paused, :Progress, []
          function :power_down, :Progress, []
          function :reset, nil, []
          function :pause, nil, []
          function :resume, nil, []
          function :power_button, nil, []
          function :sleep_button, nil, []
          function :get_power_button_handled, T_BOOL, []
          function :get_guest_entered_acpi_mode, T_BOOL, []
          function :save_state, :Progress, []
          function :adopt_saved_state, nil, [WSTRING]
          function :discard_saved_state, nil, [T_BOOL]
          function :get_device_activity, :DeviceActivity, [:DeviceType]
          function :attach_usb_device, nil, [WSTRING]
          function :detach_usb_device, :USBDevice, [WSTRING]
          function :find_usb_device_by_address, :USBDevice, [WSTRING]
          function :find_usb_device_by_id, :USBDevice, [WSTRING]
          function :create_shared_folder, nil, [WSTRING, WSTRING, T_BOOL, T_BOOL]
          function :remove_shared_folder, nil, [WSTRING]
          function :take_snapshot, :Progress, [WSTRING, WSTRING]
          function :delete_snapshot, :Progress, [WSTRING]
          function :restore_snapshot, :Progress, [:Snapshot]
          function :teleport, :Progress, [WSTRING, T_UINT32, WSTRING, T_UINT32]
        end
      end
    end
  end
end
