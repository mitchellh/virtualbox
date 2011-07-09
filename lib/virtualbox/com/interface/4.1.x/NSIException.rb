module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class NSIException < AbstractInterface
          IID = "f3a8d3b4-c424-4edc-8bf6-8974c983ba78"

          property :message, WSTRING, :readonly => true
          property :result, T_UINT32, :readonly => true
          property :name, WSTRING, :readonly => true
          property :filename, WSTRING, :readonly => true
          property :line_number, T_UINT32, :readonly => true
          property :column_number, T_UINT32, :readonly => true
          property :location, :NSIStackFrame, :readonly => true
          property :inner, :NSIException, :readonly => true
          property :data, :NSISupports, :readonly => true

          function :to_string, WSTRING, []
        end
      end
    end
  end
end