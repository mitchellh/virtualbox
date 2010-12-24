module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class MediumFormat < AbstractInterface
          IID = "89f52554-d469-4799-9fad-1705e86a08b1"

          property :id, WSTRING, :readonly => true
          property :name, WSTRING, :readonly => true
          property :file_extensions, [WSTRING], :readonly => true
          property :capabilities, T_UINT32, :readonly => true

          function :describe_properties, nil, [[:out, [WSTRING]], [:out, [WSTRING]], [:out, [:DataType]], [:out, [T_UINT32]], [:out, [WSTRING]]]
        end
      end
    end
  end
end