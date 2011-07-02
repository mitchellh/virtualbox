module VirtualBox
  module COM
    module Interface
      module Version_3_1_X
        class HWVirtExPropertyType < AbstractEnum
          map [:null, :enabled, :exclusive, :vpid, :nested_paging]
        end
      end
    end
  end
end