module VirtualBox
  module COM
    module Interface
      class HostNetworkInterfaceMediumType < AbstractEnum
        map [:unknown, :ethernet, :ppp, :slip]
      end
    end
  end
end