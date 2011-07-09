module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class DHCPServer < AbstractInterface
          IID = "6cfe387c-74fb-4ca7-bff6-973bec8af7a3"

          property :enabled, T_BOOL
          property :ip_address, WSTRING, :readonly => true
          property :network_mask, WSTRING, :readonly => true
          property :network_name, WSTRING, :readonly => true
          property :lower_ip, WSTRING, :readonly => true
          property :upper_ip, WSTRING, :readonly => true

          function :set_configuration, nil, [WSTRING, WSTRING, WSTRING, WSTRING]
          function :start, nil, [WSTRING, WSTRING, WSTRING]
          function :stop, nil, []
        end
      end
    end
  end
end