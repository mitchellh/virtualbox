module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class SerialPort < AbstractInterface
          IID = "937f6970-5103-4745-b78e-d28dcf1479a8"

          property :slot, T_UINT32, :readonly => true
          property :enabled, T_BOOL
          property :io_base, T_UINT32
          property :irq, T_UINT32
          property :host_mode, :PortMode
          property :server, T_BOOL
          property :path, WSTRING
        end
      end
    end
  end
end