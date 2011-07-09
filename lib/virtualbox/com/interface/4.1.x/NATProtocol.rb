module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class NATProtocol < AbstractEnum
          map [:udp, :tcp]
        end
      end
    end
  end
end
