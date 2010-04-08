module VirtualBox
  module COM
    module Interface
      class VRDPAuthType < AbstractEnum
        map [:null, :external, :guest]
      end
    end
  end
end