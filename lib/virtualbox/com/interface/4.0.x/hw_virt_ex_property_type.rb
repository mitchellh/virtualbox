module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class HWVirtExPropertyType < AbstractEnum
          map [:null, :enabled, :exclusive, :vpid, :nested_paging, :large_pages,
              :force]
        end
      end
    end
  end
end
