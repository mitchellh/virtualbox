module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class VirtualBoxErrorInfo < AbstractInterface
          IID = "4b86d186-407e-4f9e-8be8-e50061be8725"

          property :result_code, T_UINT32, :readonly => true
          property :interface_i_d, WSTRING, :readonly => true
          property :component, WSTRING, :readonly => true
          property :text, WSTRING, :readonly => true
          property :next, :VirtualBoxErrorInfo, :readonly => true
        end
      end
    end
  end
end