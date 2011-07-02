module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class DeviceType < AbstractEnum
          map [:null, :floppy, :dvd, :hard_disk, :network, :usb, :shared_folder]
        end
      end
    end
  end
end