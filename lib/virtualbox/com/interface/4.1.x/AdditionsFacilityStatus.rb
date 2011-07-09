module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class AdditionsFacilityStatus < AbstractEnum
          map :inactive    => 0,
              :paused      => 1,
              :pre_init    => 20,
              :init        => 30,
              :active      => 50,
              :terminating => 100,
              :terminated  => 101,
              :failed      => 800,
              :unknown     => 999
        end
      end
    end
  end
end
