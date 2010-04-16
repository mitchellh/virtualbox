module VirtualBox
  module COM
    module Interface
      class HostNetworkInterfaceType < AbstractEnum
        map [:null, :bridged, :host_only]
      end
    end
  end
end