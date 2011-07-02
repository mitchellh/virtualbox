module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class NATEngine < AbstractInterface
          IID = "4b286616-eb03-11de-b0fb-1701eca42246"

          property :network, WSTRING
          property :host_ip, WSTRING
          property :tftp_prefix, WSTRING
          property :tftp_boot_file, WSTRING
          property :tftp_next_server, WSTRING
          property :alias_mode, T_UINT32
          property :dns_pass_domain, T_BOOL
          property :dns_proxy, T_BOOL
          property :dns_use_host_resolver, T_BOOL
          property :redirects, [WSTRING], :readonly => true

          function :set_network_settings, nil, [T_UINT32, T_UINT32, T_UINT32, T_UINT32, T_UINT32]
          function :get_network_settings, nil, [[:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32]]
          function :add_redirect, nil, [WSTRING, :NATProtocol, WSTRING, T_UINT16, WSTRING, T_UINT16]
          function :remove_redirect, nil, [WSTRING]
        end
      end
    end
  end
end