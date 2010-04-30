module VirtualBox
  module COM
    module Interface
      module Version_3_0_X
        class MediumType < AbstractEnum
          map [:normal, :immutable, :write_through]
        end
      end
    end
  end
end