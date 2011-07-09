module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class CpuPropertyType < AbstractEnum
          map [:null, :pae, :synthetic]
        end
      end
    end
  end
end