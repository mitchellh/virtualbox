module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class HostUSBDeviceFilter < AbstractInterface
          IID = "4cc70246-d74a-400f-8222-3900489c0374"

          property :action, :USBDeviceFilterAction
        end
      end
    end
  end
end