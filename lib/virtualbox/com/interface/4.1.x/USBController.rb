module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class USBController < AbstractInterface
          IID = "238540fa-4b73-435a-a38e-4e1d9eab5c17"

          property :enabled, T_BOOL
          property :enabled_ehci, T_BOOL
          property :proxy_available, T_BOOL, :readonly => true
          property :usb_standard, T_UINT16, :readonly => true
          property :device_filters, [:USBDeviceFilter], :readonly => true

          function :create_device_filter, :USBDeviceFilter, [WSTRING]
          function :insert_device_filter, nil, [T_UINT32, :USBDeviceFilter]
          function :remove_device_filter, :USBDeviceFilter, [T_UINT32]
        end
      end
    end
  end
end