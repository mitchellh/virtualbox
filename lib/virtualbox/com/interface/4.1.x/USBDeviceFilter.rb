module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class USBDeviceFilter < AbstractInterface
          IID = "d6831fb4-1a94-4c2c-96ef-8d0d6192066d"

          property :name, WSTRING
          property :active, T_BOOL
          property :vendor_id, WSTRING
          property :product_id, WSTRING
          property :revision, WSTRING
          property :manufacturer, WSTRING
          property :product, WSTRING
          property :serial_number, WSTRING
          property :port, WSTRING
          property :remote, WSTRING
          property :masked_interfaces, T_UINT32
        end
      end
    end
  end
end