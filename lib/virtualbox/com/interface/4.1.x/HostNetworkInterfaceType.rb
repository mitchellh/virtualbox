module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class HostNetworkInterfaceType < AbstractEnum
          map [:null, :bridged, :host_only]
        end
      end
    end
  end
end