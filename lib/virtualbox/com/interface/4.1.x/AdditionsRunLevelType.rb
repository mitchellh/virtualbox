module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class AdditionsRunLevelType < AbstractEnum
          map :none => 0,
              :system => 1,
              :userland => 2,
              :desktop => 3
        end
      end
    end
  end
end
