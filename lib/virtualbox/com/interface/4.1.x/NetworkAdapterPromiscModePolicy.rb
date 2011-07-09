module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class NetworkAdapterPromiscModePolicty < AbstractEnum
          map :deny => 1,
              :allow_network => 2,
              :allow_all => 3
        end
      end
    end
  end
end
