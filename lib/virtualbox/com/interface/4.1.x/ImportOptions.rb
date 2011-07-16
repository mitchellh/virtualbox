module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class ImportOptions < AbstractEnum
          map :keep_all_macs => 1,
              :keep_all_nats => 2
        end
      end
    end
  end
end
