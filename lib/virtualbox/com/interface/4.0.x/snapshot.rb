module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class Snapshot < AbstractInterface
          IID = "1a2d0551-58a4-4107-857e-ef414fc42ffc"

          property :id, WSTRING, :readonly => true
          property :name, WSTRING
          property :description, WSTRING
          property :time_stamp, T_INT64, :readonly => true
          property :online, T_BOOL, :readonly => true
          property :machine, :Machine, :readonly => true
          property :parent, :Snapshot, :readonly => true
          property :children, [:Snapshot], :readonly => true
        end
      end
    end
  end
end