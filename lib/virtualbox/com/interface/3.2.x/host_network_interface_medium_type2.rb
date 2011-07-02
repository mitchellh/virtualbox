module VirtualBox
  module COM
    module Interface
      module Version_3_2_X
        class HostNetworkInterfaceMediumType < AbstractEnum
          map [:unknown, :ethernet, :ppp, :slip]
        end
      end
    end
  end
end