module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class SessionType < AbstractEnum
          map [:null, :write_lock, :remote, :shared]
        end
      end
    end
  end
end
