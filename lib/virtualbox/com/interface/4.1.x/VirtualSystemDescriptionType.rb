module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class VirtualSystemDescriptionType < AbstractEnum
          map [:null, :ignore, :os, :name, :product, :vendor, :version, :product_url, :vendor_url,
                :description, :license, :misc, :cpu, :memory, :hard_disk_controller_ide,
                :hard_disk_controller_sata, :hard_disk_controller_scsi, :hard_disk_controller_sas, :hard_disk_image,
                :floppy, :cdrom, :network_adapter, :usb_controller, :sound_card]
        end
      end
    end
  end
end
