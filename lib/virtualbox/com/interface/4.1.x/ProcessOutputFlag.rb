module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class ProcessOutputFlag < AbstractEnum
          map :none => 0,
              :stderr => 1
        end
      end
    end
  end
end
