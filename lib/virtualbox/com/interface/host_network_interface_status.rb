module VirtualBox
  module COM
    module Interface
      class HostNetworkInterfaceStatus < AbstractEnum
        map [:unknown, :up, :down]
      end
    end
  end
end