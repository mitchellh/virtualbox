module VirtualBox
  module COM
    module Interface
      module Version_3_2_X
        class CpuPropertyType < AbstractEnum
          map [:null, :pae, :synthetic]
        end
      end
    end
  end
end