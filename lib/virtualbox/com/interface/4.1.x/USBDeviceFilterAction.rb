module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class USBDeviceFilterAction < AbstractEnum
          map [:null, :ignore, :hold]
        end
      end
    end
  end
end