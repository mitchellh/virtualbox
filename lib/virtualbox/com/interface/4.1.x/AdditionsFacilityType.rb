module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class AdditionsFacilityType < AbstractEnum
          map :none              => 0,
              :vbox_guest_driver => 20,
              :vbox_server       => 100,
              :vbox_tray_client  => 101,
              :seamless          => 1000,
              :graphics          => 1100,
              :all               => 2147483646
        end
      end
    end
  end
end
