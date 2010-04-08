module VirtualBox
  module COM
    module Interface
      class USBDeviceState < AbstractEnum
        map [:not_supported, :unavailable, :busy, :available, :help, :captured]
      end
    end
  end
end