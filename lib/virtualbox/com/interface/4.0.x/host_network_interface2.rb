module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class HostNetworkInterface < AbstractInterface
          IID = "ce6fae58-7642-4102-b5db-c9005c2320a8"

          property :name, WSTRING, :readonly => true
          property :id, WSTRING, :readonly => true
          property :network_name, WSTRING, :readonly => true
          property :dhcp_enabled, T_BOOL, :readonly => true
          property :ip_address, WSTRING, :readonly => true
          property :network_mask, WSTRING, :readonly => true
          property :ip_v6_supported, T_BOOL, :readonly => true
          property :ip_v6_address, WSTRING, :readonly => true
          property :ip_v6_network_mask_prefix_length, T_UINT32, :readonly => true
          property :hardware_address, WSTRING, :readonly => true
          property :medium_type, :HostNetworkInterfaceMediumType, :readonly => true
          property :status, :HostNetworkInterfaceStatus, :readonly => true
          property :interface_type, :HostNetworkInterfaceType, :readonly => true

          function :enable_static_ip_config, nil, [WSTRING, WSTRING]
          function :enable_static_ip_config_v6, nil, [WSTRING, T_UINT32]
          function :enable_dynamic_ip_config, nil, []
          function :dhcp_rediscover, nil, []
        end
      end
    end
  end
end