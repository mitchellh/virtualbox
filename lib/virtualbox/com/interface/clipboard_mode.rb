module VirtualBox
  module COM
    module Interface
      class ClipboardMode < AbstractEnum
        map [:disabled, :host_to_guest, :guest_to_host, :bidirectional]
      end
    end
  end
end