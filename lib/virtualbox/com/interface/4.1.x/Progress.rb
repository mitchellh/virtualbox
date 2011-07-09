module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
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
          property :operation_weight, T_UINT32, :readonly => true
          property :timeout, T_UINT32

          function :set_current_operation_progress, nil, [T_UINT32]
          function :set_next_operation, nil, [WSTRING, T_UINT32]
          function :wait_for_completion, nil, [T_INT32]
          function :wait_for_operation_completion, nil, [T_UINT32, T_INT32]
          function :cancel, nil, []

          # This method blocks the execution while the operations represented
          # by this {Progress} object execute, but yields a block every `x`
          # percent (interval given in parameters).
          def wait(interval_percent=1)
            # If no block is given we just wait until completion, not worrying
            # about tracking percentages.
            if !block_given?
              wait_for_completion(-1)
              return
            end

            # Initial value forces the 0% yield
            last_reported = -100

            while true
              delta = percent - last_reported
              last_reported += delta
              yield self if delta >= interval_percent

              # This either sleeps for half a second or returns on
              # completion
              wait_for_completion(500)

              break if completed || canceled

              # Pass off execution so other threads can run
              Thread.pass
            end
          end
        end
      end
    end
  end
end
