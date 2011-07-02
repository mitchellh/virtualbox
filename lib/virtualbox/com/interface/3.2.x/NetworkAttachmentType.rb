module VirtualBox
  module COM
    module Interface
      module Version_3_2_X
        class NetworkAttachmentType < AbstractEnum
          map [:null, :nat, :bridged, :internal, :host_only, :vde]
        end
      end
    end
  end
end