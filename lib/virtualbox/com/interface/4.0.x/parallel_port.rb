module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class ParallelPort < AbstractInterface
          IID = "0c925f06-dd10-4b77-8de8-294d738c3214"

          property :slot, T_UINT32, :readonly => true
          property :enabled, T_BOOL
          property :io_base, T_UINT32
          property :irq, T_UINT32
          property :path, WSTRING
        end
      end
    end
  end
end