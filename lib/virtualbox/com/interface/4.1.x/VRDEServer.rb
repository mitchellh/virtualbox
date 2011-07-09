module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class VRDEServer < AbstractInterface
          IID = "72e671bc-1712-4052-ad6b-e45e76d9d3e4"

          property :enabled, T_BOOL
          property :auth_type, :AuthType
          property :auth_timeout, T_UINT32
          property :allow_multi_connection, T_BOOL
          property :reuse_single_connection, T_BOOL
          property :vrde_ext_pack, WSTRING
          property :auth_library, WSTRING
          property :vrde_properties, [WSTRING], :readonly => true

          function :set_vrde_property, nil, [WSTRING, WSTRING]
          function :get_vrde_property, WSTRING, [WSTRING]
        end
      end
    end
  end
end
