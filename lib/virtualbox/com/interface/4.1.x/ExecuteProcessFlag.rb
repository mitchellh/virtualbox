module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class ExecuteProcessFlag < AbstractEnum
          map :none => 0,
              :wait_for_process_start_only => 1,
              :ignore_orphaned_processes => 2,
              :hidden => 4,
              :no_profile => 8
        end
      end
    end
  end
end
