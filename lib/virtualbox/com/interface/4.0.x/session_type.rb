module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class SessionType < AbstractEnum
          map [:null, :direct, :remote, :existing]
        end
      end
    end
  end
end