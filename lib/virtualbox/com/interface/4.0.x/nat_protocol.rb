module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class NATProtocol < AbstractEnum
          map [:udp, :tcp]
        end
      end
    end
  end
end