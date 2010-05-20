module VirtualBox
  module COM
    module Interface
      module Version_3_1_X
        class VirtualSystemDescriptionValueType < AbstractEnum
          map [:null, :reference, :original, :auto, :extra_config]
        end
      end
    end
  end
end
