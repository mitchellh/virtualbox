module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class GuestDirEntry < AbstractInterface
          IID = "20a66efc-c2f6-4438-826f-38454c04369e"

          property :node_id, T_INT64, :readonly => true
          property :name, WSTRING, :readonly => true
          property :type, :GuestDirEntryType, :readonly => true
        end
      end
    end
  end
end
