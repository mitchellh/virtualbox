module VirtualBox
  module COM
    module Interface
      class NetworkAttachmentType < AbstractEnum
        map [:null, :nat, :bridged, :internal, :host_only]
      end
    end
  end
end