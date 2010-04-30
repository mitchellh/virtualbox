module VirtualBox
  module COM
    module Interface
      module Version_3_0_X
        class VirtualSystemDescriptionValueType < AbstractEnum
          map [:null, :reference, :original, :auto, :extra_config]
        end
      end
    end
  end
end
