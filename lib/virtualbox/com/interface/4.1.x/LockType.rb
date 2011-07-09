module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class LockType < AbstractEnum
          map [:null, :shared, :write]
        end
      end
    end
  end
end
