module VirtualBox
  module COM
    module Interface
      class AudioControllerType < AbstractEnum
        map [:ac97, :sb16]
      end
    end
  end
end