module VirtualBox
  module COM
    module Interface
      module Version_3_2_X
        class USBDeviceState < AbstractEnum
          map [:not_supported, :unavailable, :busy, :available, :help, :captured]
        end
      end
    end
  end
end