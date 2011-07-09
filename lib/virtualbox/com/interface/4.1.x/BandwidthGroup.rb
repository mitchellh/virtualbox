module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class BandwidthGroup < AbstractInterface
          IID_STR = "BADEA2D7-0261-4146-89F0-6A57CC34833D"

          property :name, WSTRING, :readonly => true
          property :type, :BandwidthGroupType, :readonly => true
          property :reference, T_UINT32, :readonly => true
          property :max_mb_per_sec, T_UINT32, :readonly => true
        end
      end
    end
  end
end
