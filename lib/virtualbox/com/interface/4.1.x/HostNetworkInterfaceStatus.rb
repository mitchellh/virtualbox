module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class HostNetworkInterfaceStatus < AbstractEnum
          map [:unknown, :up, :down]
        end
      end
    end
  end
end
