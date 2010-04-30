module VirtualBox
  module COM
    module Interface
      module Version_3_0_X
        class USBDeviceState < AbstractEnum
          map [:not_supported, :unavailable, :busy, :available, :help, :captured]
        end
      end
    end
  end
end