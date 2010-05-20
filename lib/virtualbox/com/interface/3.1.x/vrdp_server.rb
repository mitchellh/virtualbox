module VirtualBox
  module COM
    module Interface
      module Version_3_1_X
        class VRDPServer < AbstractInterface
          IID = "72e671bc-1712-4052-ad6b-e45e76d9d3e4"

          property :enabled, T_BOOL
          property :ports, WSTRING
          property :net_address, WSTRING
          property :auth_type, :VRDPAuthType
          property :auth_timeout, T_UINT32
          property :allow_multi_connection, T_BOOL
          property :reuse_single_connection, T_BOOL
        end
      end
    end
  end
end