module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class NetworkAdapter < AbstractInterface
          IID = "65607a27-2b73-4d43-b4cc-0ba2c817fbde"

          property :adapter_type, :NetworkAdapterType
          property :slot, T_UINT32, :readonly => true
          property :enabled, T_BOOL
          property :mac_address, WSTRING
          property :attachment_type, :NetworkAttachmentType
          property :bridged_interface, WSTRING
          property :host_only_interface, WSTRING
          property :internal_network, WSTRING
          property :nat_network, WSTRING
          property :generic_driver, WSTRING
          property :cable_connected, T_BOOL
          property :line_speed, T_UINT32
          property :promisc_mode_policy, :NetworkAdapterPromiscModePolicy
          property :trace_enabled, T_BOOL
          property :trace_file, WSTRING
          property :nat_driver, :NATEngine, :readonly => true
          property :boot_priority, T_UINT32
          property :bandwidth_group, :BandwidthGroup

          function :get_property, WSTRING, [WSTRING]
          function :set_property, nil, [WSTRING, WSTRING]
          function :get_properties, [WSTRING], [WSTRING, [:out, WSTRING]]
        end
      end
    end
  end
end
