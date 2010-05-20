module VirtualBox
  module COM
    module Interface
      module Version_3_2_X
        class NATProtocol < AbstractEnum
          map [:udp, :tcp]
        end
      end
    end
  end
end