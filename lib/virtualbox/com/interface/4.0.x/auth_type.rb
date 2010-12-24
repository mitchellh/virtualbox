module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class AuthType < AbstractEnum
          map [:null, :external, :guest]
        end
      end
    end
  end
end
