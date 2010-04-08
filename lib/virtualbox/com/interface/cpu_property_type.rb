module VirtualBox
  module COM
    module Interface
      class CpuPropertyType < AbstractEnum
        map [:null, :pae, :synthetic]
      end
    end
  end
end