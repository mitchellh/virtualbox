module VirtualBox
  module COM
    module Interface
      class SessionState < AbstractEnum
        map [:null, :closed, :open, :spawning, :closing]
      end
    end
  end
end