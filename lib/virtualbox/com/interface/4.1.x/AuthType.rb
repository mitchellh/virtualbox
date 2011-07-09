module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class AuthType < AbstractEnum
          map [:null, :external, :guest]
        end
      end
    end
  end
end
