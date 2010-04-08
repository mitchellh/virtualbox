module VirtualBox
  module COM
    module Interface
      class HostNetworkInterfaceType < AbstractEnum
        map [:bridged, :host_only]
      end
    end
  end
end