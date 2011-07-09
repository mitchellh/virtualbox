module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class NetworkAdapterType < AbstractEnum
          map [:null, :Am79C970A, :Am79C973, :I82540EM, :I82543GC, :I82545EM, :Virtio]
        end
      end
    end
  end
end