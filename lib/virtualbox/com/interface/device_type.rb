module VirtualBox
  module COM
    module Interface
      class DeviceType < AbstractEnum
        map [:null, :floppy, :dvd, :hard_disk, :network, :usb, :shared_folder]
      end
    end
  end
end