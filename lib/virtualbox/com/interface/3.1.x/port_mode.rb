module VirtualBox
  module COM
    module Interface
      module Version_3_1_X
        class PortMode < AbstractEnum
          map [:disconnected, :host_pipe, :host_device, :raw_file]
        end
      end
    end
  end
end
