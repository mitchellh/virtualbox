module VirtualBox
  module COM
    module Interface
      class MediumType < AbstractEnum
        map [:normal, :immutable, :write_through]
      end
    end
  end
end