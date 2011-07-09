module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class CpuPropertyType < AbstractEnum
          map [:null, :pae, :synthetic]
        end
      end
    end
  end
end
