module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class SessionState < AbstractEnum
          map [:null, :closed, :open, :spawning, :closing]
        end
      end
    end
  end
end
