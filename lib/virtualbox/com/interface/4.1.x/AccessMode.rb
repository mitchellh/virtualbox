module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class AccessMode < AbstractEnum
          map [:null, :read_only, :read_write]
        end
      end
    end
  end
end
