module VirtualBox
  module COM
    module Interface
      module Version_3_1_X
        class VRDPAuthType < AbstractEnum
          map [:null, :external, :guest]
        end
      end
    end
  end
end