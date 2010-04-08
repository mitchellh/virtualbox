module VirtualBox
  module COM
    module Interface
      class SessionType < AbstractEnum
        map [:null, :direct, :remote, :existing]
      end
    end
  end
end