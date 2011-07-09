module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class NetworkAttachmentType < AbstractEnum
          map [:null, :nat, :bridged, :internal, :host_only, :generic]
        end
      end
    end
  end
end
