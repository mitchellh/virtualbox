module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class AdditionsFacilityClass < AbstractEnum
          map :none        => 0,
              :driver      => 10,
              :service     => 30,
              :program     => 50,
              :feature     => 100,
              :third_party => 999,
              :all         => 2147483646
        end
      end
    end
  end
end
