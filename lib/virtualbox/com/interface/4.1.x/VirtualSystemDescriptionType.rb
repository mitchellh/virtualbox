module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class VirtualSystemDescriptionType < AbstractEnum
          map :ignore => 1,
              :os => 2,
              :name => 3,
              :product => 4,
              :vendor => 5,
              :version => 6,
              :product_url => 7,
              :vendor_url => 8,
              :description => 9,
              :license => 10,
              :misc => 11,
              :cpu => 12,
              :memory => 13,
              :hard_disk_controller_ide => 14,
              :hard_disk_controller_sata => 15,
              :hard_disk_controller_scsi => 16,
              :hard_disk_controller_sas => 17,
              :hard_disk_image => 18,
              :floppy => 19,
              :cdrom => 20,
              :network_adapter => 21,
              :usb_controller => 22,
              :sound_card => 23,
              :settings_file => 24
        end
      end
    end
  end
end
