module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class AdditionsFacility < AbstractInterface
          IID = "54992946-6af1-4e49-98ec-58b558b7291e"

          property :class_type, :AdditionsFacilityClass, :readonly => true
          property :last_updated, T_INT64, :readonly => true
          property :name, WSTRING, :readonly => true
          property :status, :AdditionsFacilityStatus, :readonly => true
          property :type, :AdditionsFacilityType, :readonly => true
        end
      end
    end
  end
end
