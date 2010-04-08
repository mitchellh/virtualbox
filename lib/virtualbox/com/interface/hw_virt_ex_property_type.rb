module VirtualBox
  module COM
    module Interface
      class HWVirtExPropertyType < AbstractEnum
        map [:null, :enabled, :exclusive, :vpid, :nested_paging]
      end
    end
  end
end