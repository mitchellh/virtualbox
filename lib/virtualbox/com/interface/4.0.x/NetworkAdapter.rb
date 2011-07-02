module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class NetworkAdapter < AbstractInterface
          IID = "65607a27-2b73-4d43-b4cc-0ba2c817fbde"

          property :adapter_type, :NetworkAdapterType
          property :slot, T_UINT32, :readonly => true
          property :enabled, T_BOOL
          property :mac_address, WSTRING
          property :attachment_type, :NetworkAttachmentType, :readonly => true
          property :host_interface, WSTRING
          property :internal_network, WSTRING
          property :nat_network, WSTRING
          property :vde_network, WSTRING
          property :cable_connected, T_BOOL
          property :line_speed, T_UINT32
          property :trace_enabled, T_BOOL
          property :trace_file, WSTRING
          property :nat_driver, :NATEngine, :readonly => true
          property :boot_priority, T_UINT32
          property :bandwidth_limit, T_UINT32

          function :attach_to_nat, nil, []
          function :attach_to_bridged_interface, nil, []
          function :attach_to_internal_network, nil, []
          function :attach_to_host_only_interface, nil, []
          function :attach_to_vde, nil, []
          function :detach, nil, []
        end
      end
    end
  end
end
