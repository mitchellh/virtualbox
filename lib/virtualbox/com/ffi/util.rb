module VirtualBox
  module COM
    module FFI
      # Class which contains many class-level utility methods to assist
      # with the FFI interface. These functions range from converting a
      # function spec to a FFI parameter list to dereferencing pointers.
      class Util
        class << self
          # Finds and returns the `COM::Interface` class associated with the type.
          # If the class does not exist, a `NameError` will be raised.
          #
          # @return [Class]
          def interface_klass(type)
            ::VirtualBox::COM::Util.versioned_interface(type)
          end

          # Finds the versioned interface for the FFI module.
          #
          # @return [Class]
          def versioned_interface(interface)
            ::VirtualBox::COM::FFI.const_get(::VirtualBox::COM::Util.version_const).const_get(interface)
          end

          # Converts a function spec from {AbstractInterface} to an FFI
          # function spec. This handles custom types (unicode strings,
          # arrays, and out-parameters) and will return a perfectly valid
          # array ready to be passed into `callback`.
          #
          # @param [Array] spec The function spec
          # @return [Array]
          def spec_to_ffi(spec)
            spec = spec.collect do |item|
              if item.is_a?(Array) && item[0] == :out
                if item[1].is_a?(Array)
                  # The out is an array of items, so we add in two pointers:
                  # one for size and one for the array
                  [:pointer, :pointer]
                else
                  # A regular out parameter is just a single pointer
                  :pointer
                end
              elsif item.is_a?(Array) && item.length == 1
                # The parameter is an array of somethings
                [T_UINT32, :pointer]
              elsif item == WSTRING
                # Unicode strings are simply pointers
                :pointer
              elsif item.to_s[0,1] == item.to_s[0,1].upcase
                begin
                  # Try to get the class from the interfaces
                  interface = interface_klass(item.to_sym)

                  if interface.superclass == COM::AbstractInterface
                    :pointer
                  elsif interface.superclass == COM::AbstractEnum
                    T_UINT32
                  end
                rescue NameError
                  # Default to a pointer, since not all interfaces are implemented
                  :pointer
                end
              else
                # Unknown items are simply passed as-is, hopefully FFI
                # will catch any problems
                item
              end
            end

            # Prepend a :pointer to represent the `this` parameter required
            # for the FFI parameter lists
            spec.unshift(:pointer).flatten
          end

          # An "almost complete" camel-caser. Camel cases a string with a few
          # exceptions. For example: `get_foo` becomes `GetFoo`, but `get_os_type`
          # becomes `GetOSType` since `os` is a special case.
          #
          # @param [String] string The string to camel case
          # @return [String]
          def camelize(string)
            special_cases = {
              "os" => "OS",
              "dhcp" => "DHCP",
              "dvd" => "DVD",
              "usb" => "USB",
              "vram" => "VRAM",
              "3d" => "3D",
              "bios" => "BIOS",
              "vrdp" => "VRDP",
              "vrde" => "VRDE",
              "hw" => "HW",
              "png" => "PNG",
              "io" => "IO",
              "apic" => "APIC",
              "acpi" => "ACPI",
              "pxe" => "PXE",
              "nat" => "NAT",
              "ide" => "IDE",
              "vfs" => "VFS",
              "ip" => "IP",
              "vdi" => "VDI",
              "cpu" => "CPU",
              "ram" => "RAM",
              "hdd" => "HDD",
              "rtc" => "RTC",
              "utc" => "UTC",
              "io" => "IO",
              "vm" => "VM"
            }

            parts = string.to_s.split(/_/).collect do |part|
              special_cases[part] || part.capitalize
            end

            parts.join("")
          end
        end
      end
    end
  end
end
