module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class MediumAttachment < AbstractInterface
          IID = "e58eb3eb-8627-428b-bdf8-34487c848de5"

          property :medium, :Medium, :readonly => true
          property :controller, WSTRING, :readonly => true
          property :port, T_INT32, :readonly => true
          property :device, T_INT32, :readonly => true
          property :type, :DeviceType, :readonly => true
          property :passthrough, T_BOOL, :readonly => true
          property :temporary_eject, T_BOOL, :readonly => true
          property :is_ejected, T_BOOL, :readonly => true
          property :bandwidth_group, :BandwidthGroup, :readonly => true
        end
      end
    end
  end
end
