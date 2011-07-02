module VirtualBox
  module COM
    module Interface
      module Version_3_2_X
        class HWVirtExPropertyType < AbstractEnum
          map [:null, :enabled, :exclusive, :vpid, :nested_paging, :large_pages]
        end
      end
    end
  end
end