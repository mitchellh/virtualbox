module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class CloneOptions < AbstractEnum
          map :link => 1
              :keep_all_macs => 2,
              :keep_nat_macs => 3,
              :keep_disk_names => 4
        end
      end
    end
  end
end
