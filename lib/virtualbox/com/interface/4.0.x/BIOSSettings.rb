module VirtualBox
  module COM
    module Interface
      module Version_4_0_X
        class BIOSSettings < AbstractInterface
          IID = "38b54279-dc35-4f5e-a431-835b867c6b5e"

          property :logo_fade_in, T_BOOL
          property :logo_fade_out, T_BOOL
          property :logo_display_time, T_UINT32
          property :logo_image_path, WSTRING
          property :boot_menu_mode, :BIOSBootMenuMode
          property :acpi_enabled, T_BOOL
          property :io_apic_enabled, T_BOOL
          property :time_offset, T_INT64
          property :pxe_debug_enabled, T_BOOL
        end
      end
    end
  end
end