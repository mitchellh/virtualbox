module VirtualBox
  module COM
    module Interface
      class USBDeviceFilterAction < AbstractEnum
        map [:null, :ignore, :hold]
      end
    end
  end
end