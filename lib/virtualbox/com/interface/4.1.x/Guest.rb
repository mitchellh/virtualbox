module VirtualBox
  module COM
    module Interface
      module Version_4_1_X
        class Guest < AbstractInterface
          IID = "af2766d9-ebff-455f-b5ce-c6f855b8f584"

          property :os_type_id, WSTRING, :readonly => true
          property :additions_run_level, :AdditionsRunLevelType, :readonly => true
          property :additions_version, WSTRING, :readonly => true
          property :facilities, [:AdditionsFacility], :readonly => true
          property :memory_balloon_size, T_UINT32
          property :statistics_update_interval, T_UINT32

          function :internal_get_statistics, nil, [[:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32], [:out, T_UINT32]]
          function :get_facility_status, :AdditionsFacilityStatus, [:AdditionsFacilityType, [:out, T_UINT64]]
          function :get_additions_status, T_BOOL, [:AdditionsRunLevelType]
          function :set_credentials, nil, [WSTRING, WSTRING, WSTRING, T_BOOL]
          function :execute_process, :Progress, [WSTRING, T_UINT32, [WSTRING], [WSTRING], WSTRING, WSTRING, T_UINT32, [:out, T_UINT32]]
          function :get_process_output, [T_UINT8], [T_UINT32, T_UINT32, T_UINT32, T_INT64]
          function :get_process_status, :ExecuteProcessStatus, [T_UINT32, [:out, T_UINT32], [:out, T_UINT32]]
          function :copy_from_guest, :Progress, [WSTRING, WSTRING, WSTRING, WSTRING, T_UINT32]
          function :copy_to_guest, :Progress, [WSTRING, WSTRING, WSTRING, WSTRING, T_UINT32]
          function :directory_close, nil, [T_UINT32]
          function :directory_create, nil, [WSTRING, WSTRING, WSTRING, T_UINT32, T_UINT32]
          function :directory_open, T_UINT32, [WSTRING, WSTRING, T_UINT32, WSTRING, WSTRING]
          function :directory_read, :GuestDirEntry, [T_UINT32]
          function :file_exists, T_BOOL, [WSTRING, WSTRING, WSTRING]
          function :file_query_size, T_INT64, [WSTRING, WSTRING, WSTRING]
          function :set_process_input, T_UINT32, [T_UINT32, T_UINT32, T_UINT32, [T_UINT8]]
          function :update_guest_additions, :Progress, [WSTRING, T_UINT32]
        end
      end
    end
  end
end
