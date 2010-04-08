module VirtualBox
  module COM
    module Interface
      class Progress < AbstractInterface
        IID = "856aa038-853f-42e2-acf7-6e7b02dbe294"

        property :id, WSTRING, :readonly => true
        property :description, WSTRING, :readonly => true
        property :initiator, :NSISupports, :readonly => true
        property :cancelable, T_BOOL, :readonly => true
        property :percent, T_UINT32, :readonly => true
        property :time_remaining, T_INT32, :readonly => true
        property :completed, T_BOOL, :readonly => true
        property :canceled, T_BOOL, :readonly => true
        property :result_code, T_INT32, :readonly => true
        property :error_info, :VirtualBoxErrorInfo, :readonly => true
        property :operation_count, T_UINT32, :readonly => true
        property :operation, T_UINT32, :readonly => true
        property :operation_description, WSTRING, :readonly => true
        property :operation_percent, T_UINT32, :readonly => true
        property :timeout, T_UINT32

        function :set_current_operation_progress, nil, [T_UINT32]
        function :set_next_operation, nil, [WSTRING, T_UINT32]
        function :wait_for_completion, nil, [T_INT32]
        function :wait_for_operation_completion, nil, [T_UINT32, T_INT32]
        function :cancel, nil, []
      end
    end
  end
end