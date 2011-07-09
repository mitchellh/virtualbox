module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class SettingsVersion < AbstractEnum
          map :v1_0 => 1,
              :v1_1 => 2,
              :v1_2 => 3,
              :v1_3pre => 4,
              :v1_3 => 5,
              :v1_4 => 6,
              :v1_5 => 7,
              :v1_6 => 8,
              :v1_7 => 9,
              :v1_8 => 10,
              :v1_9 => 11,
              :v1_10 => 12,
              :v1_11 => 13,
              :v1_12 => 14,
              :future => 99999
        end
      end
    end
  end
end
