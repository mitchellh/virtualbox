module VirtualBox
  module COM
    module Interface
      class VirtualSystemDescriptionValueType < AbstractEnum
        map [:null, :reference, :original, :auto, :extra_config]
      end
    end
  end
end
