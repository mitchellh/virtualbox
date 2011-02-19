module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class BandwidthGroupType < AbstractEnum
          map [:null, :disk, :network]
        end
      end
    end
  end
end
