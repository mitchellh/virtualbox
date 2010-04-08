module VirtualBox
  module COM
    module Interface
      class PortMode < AbstractEnum
        map [:disconnected, :host_pipe, :host_device, :raw_file]
      end
    end
  end
end
