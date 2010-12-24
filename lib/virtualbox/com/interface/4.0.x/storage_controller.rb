module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class StorageController < AbstractInterface
          IID = "6bf8335b-d14a-44a5-9b45-ddc49ce7d5b2"

          property :name, WSTRING, :readonly => true
          property :max_devices_per_port_count, T_UINT32, :readonly => true
          property :min_port_count, T_UINT32, :readonly => true
          property :max_port_count, T_UINT32, :readonly => true
          property :instance, T_UINT32
          property :port_count, T_UINT32
          property :bus, :StorageBus, :readonly => true
          property :controller_type, :StorageControllerType
          property :use_host_io_cache, T_BOOL

          function :get_ide_emulation_port, T_INT32, [T_INT32]
          function :set_ide_emulation_port, nil, [T_INT32, T_INT32]
        end
      end
    end
  end
end