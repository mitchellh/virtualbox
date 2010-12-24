module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class Medium < AbstractInterface
          IID = "aa8167ba-df72-4738-b740-9b84377ba9f1"

          property :id, WSTRING, :readonly => true
          property :description, WSTRING
          property :state, :MediumState, :readonly => true
          property :variant, T_UINT64, :readonly => true
          property :location, WSTRING
          property :name, WSTRING, :readonly => true
          property :device_type, :DeviceType, :readonly => true
          property :host_drive, T_BOOL, :readonly => true
          property :size, T_UINT64, :readonly => true
          property :format, WSTRING, :readonly => true
          property :medium_format, :MediumFormat, :readonly => true
          property :type, :MediumType
          property :parent, :Medium, :readonly => true
          property :children, [:Medium], :readonly => true
          property :base, :Medium, :readonly => true
          property :read_only, T_BOOL, :readonly => true
          property :logical_size, T_UINT64, :readonly => true
          property :auto_reset, T_BOOL
          property :last_access_error, WSTRING, :readonly => true
          property :machine_ids, [WSTRING], :readonly => true

          function :set_ids, nil, [T_BOOL, WSTRING, T_BOOL, WSTRING]
          function :refresh_state, :MediumState, []
          function :get_snapshot_ids, [WSTRING], [WSTRING]
          function :lock_read, :MediumState, []
          function :unlock_read, :MediumState, []
          function :lock_write, :MediumState, []
          function :unlock_write, :MediumState, []
          function :close, nil, []
          function :get_property, WSTRING, [WSTRING]
          function :set_property, nil, [WSTRING, WSTRING]
          function :get_properties, [WSTRING], [WSTRING, [:out, [WSTRING]]]
          function :set_properties, nil, [[WSTRING], [WSTRING]]
          function :create_base_storage, :Progress, [T_UINT64, :MediumVariant]
          function :delete_storage, :Progress, []
          function :create_diff_storage, :Progress, [:Medium, :MediumVariant]
          function :merge_to, :Progress, [:Medium]
          function :clone_to, :Progress, [:Medium, :MediumVariant, :Medium]
          function :compact, :Progress, []
          function :resize, :Progress, [T_UINT64]
          function :reset, :Progress, []
        end
      end
    end
  end
end
