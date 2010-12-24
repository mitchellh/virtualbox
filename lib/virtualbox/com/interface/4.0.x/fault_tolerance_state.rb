module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class FaultToleranceState < AbstractEnum
          map [:null, :inactive, :master, :standby]
        end
      end
    end
  end
end
