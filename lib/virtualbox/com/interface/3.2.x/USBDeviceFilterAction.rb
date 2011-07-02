module VirtualBox
  module COM
    module Interface
      module Version_3_2_X
        class USBDeviceFilterAction < AbstractEnum
          map [:null, :ignore, :hold]
        end
      end
    end
  end
end