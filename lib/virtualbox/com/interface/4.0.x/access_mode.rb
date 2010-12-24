module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class AccessMode < AbstractEnum
          map [:null, :access_mode_read_only, :access_mode_read_write]
        end
      end
    end
  end
end
