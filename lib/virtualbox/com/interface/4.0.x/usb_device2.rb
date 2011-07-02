module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class USBDevice < AbstractInterface
          IID = "f8967b0b-4483-400f-92b5-8b675d98a85b"

          property :id, WSTRING, :readonly => true
          property :vendor_id, T_UINT16, :readonly => true
          property :product_id, T_UINT16, :readonly => true
          property :revision, T_UINT16, :readonly => true
          property :manfacturer, WSTRING, :readonly => true
          property :product, WSTRING, :readonly => true
          property :serial_number, WSTRING, :readonly => true
          property :address, WSTRING, :readonly => true
          property :port, T_UINT16, :readonly => true
          property :version, T_UINT16, :readonly => true
          property :port_version, T_UINT16, :readonly => true
          property :remote, T_BOOL, :readonly => true
        end
      end
    end
  end
end