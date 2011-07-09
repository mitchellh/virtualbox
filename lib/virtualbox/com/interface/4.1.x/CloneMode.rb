module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class CloneMode < AbstractEnum
          map :machine_state => 1,
              :machine_and_child_states => 2,
              :all_status => 3
        end
      end
    end
  end
end
