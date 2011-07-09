module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class VirtualSystemDescription < AbstractInterface
          IID = "d7525e6c-531a-4c51-8e04-41235083a3d8"

          property :count, T_UINT32, :readonly => true

          function :get_description, nil, [[:out, [:VirtualSystemDescriptionType]], [:out, [WSTRING]], [:out, [WSTRING]], [:out, [WSTRING]], [:out, [WSTRING]]]
          function :get_description_by_type, nil, [:VirtualSystemDescriptionType, [:out, [:VirtualSystemDescriptionType]], [:out, [WSTRING]], [:out, [WSTRING]], [:out, [WSTRING]], [:out, [WSTRING]]]
          function :get_values_by_type, [WSTRING], [:VirtualSystemDescriptionType, :VirtualSystemDescriptionValueType]
          function :set_final_values, nil, [[T_BOOL], [WSTRING], [WSTRING]]
          function :add_description, nil, [:VirtualSystemDescriptionType, WSTRING, WSTRING]
        end
      end
    end
  end
end