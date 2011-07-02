module VirtualBox
  module COM
    module FFI
      # Creates all the FFI classes for a given version.
      def self.for_version(version, &block)
        @__module = Module.new
        ::VirtualBox::COM::Util.set_interface_version(version)
        const_set(::VirtualBox::COM::Util.version_const, @__module)
        instance_eval(&block)
        @__module = Kernel
      end

      # Returns a Class which creates an FFI interface to the specified
      # com interface and potentially a parent class as well.
      def self.create_interface(interface, parent=nil)
        klass = Class.new(Interface)
        @__module.const_set(interface, klass)
        klass.com_interface(interface, parent)
        klass
      end

      # Creates all the interfaces for the FFI implementation. Eventually this
      # file should be conditionally loaded based on OS, so that Windows users
      # don't have to wait for all this translation to occur.
      def self.setup(version)
        # TODO: This is so hacky and hard to maintain. Can we
        # programatically get the modules in a namespace and
        # instantiate them somehow?
        for_version version do
          create_interface(:NSISupports)
          create_interface(:NSIException, :NSISupports)
          create_interface(:Session, :NSISupports)
          create_interface(:VirtualBox, :NSISupports)
          create_interface(:Appliance, :NSISupports)
          create_interface(:AudioAdapter, :NSISupports)
          create_interface(:BIOSSettings, :NSISupports)
          create_interface(:Console, :NSISupports)
          create_interface(:DHCPServer, :NSISupports)
          create_interface(:GuestOSType, :NSISupports)
          create_interface(:Host, :NSISupports)
          create_interface(:HostNetworkInterface, :NSISupports)
          create_interface(:Machine, :NSISupports)
          create_interface(:Medium, :NSISupports)
          create_interface(:MediumAttachment, :NSISupports)
          create_interface(:MediumFormat, :NSISupports)
          create_interface(:NetworkAdapter, :NSISupports)
          create_interface(:ParallelPort, :NSISupports)
          create_interface(:Progress, :NSISupports)
          create_interface(:SerialPort, :NSISupports)
          create_interface(:SharedFolder, :NSISupports)
          create_interface(:Snapshot, :NSISupports)
          create_interface(:StorageController, :NSISupports)
          create_interface(:SystemProperties, :NSISupports)
          create_interface(:USBController, :NSISupports)
          create_interface(:USBDevice, :NSISupports)
          create_interface(:USBDeviceFilter, :NSISupports)
          create_interface(:VirtualBoxErrorInfo, :NSIException)
          create_interface(:VirtualSystemDescription, :NSISupports)

          create_interface(:HostUSBDevice, :USBDevice)
          create_interface(:HostUSBDeviceFilter, :USBDeviceFilter)

          # 3.1.x, 3.2.x
          if ["3.1.x", "3.2.x"].include?(version)
            create_interface(:VRDPServer, :NSISupports)
          end

          # 3.2.x, 4.0.x
          if ["3.2.x", "4.0.x"].include?(version)
            create_interface(:NATEngine, :NSISupports)
          end

          # 4.0.x interfaces
          if version == "4.0.x"
            create_interface(:BandwidthControl, :NSISupports)
            create_interface(:VRDEServer, :NSISupports)
          end
        end
      end
    end
  end
end
