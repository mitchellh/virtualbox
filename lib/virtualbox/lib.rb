require 'virtualbox/ext/platform'

module VirtualBox
  # Used by the rest of the VirtualBox library to interface with
  # the VirtualBox XPCOM library (VBoxXPCOMC). Most users will never need
  # to interface with this class directly, except other to set the path to
  # the `VBoxXPCOMC` lib.
  #
  # # Setting the Path to the VBoxXPCOMC Library
  #
  # This won't be necessary for 95% of users, and won't be necessary at all
  # for windows users. But for unix users, the VirtualBox gem uses a dynamic
  # library named `VBoxXPCOMC` to interface with VirtualBox. The gem does its
  # best to guess the path to this gem based on the operating system ruby is
  # running on, but in the case you get an error about it missing, you can
  # easily set it:
  #
  #     VirtualBox::Lib.lib_path = "/path/to/VBoxXPCOMC.so"
  #
  # **Windows users will never need to do this.**
  #
  class Lib
    @@lib_path = nil
    @@lib = nil

    attr_reader :interface
    attr_reader :virtualbox
    attr_reader :session

    class << self
      # Resets the initialized library (if there is any). This is primarily only
      # used for testing.
      def reset!
        @@lib = nil
      end

      # The singleton instance of Lib.
      #
      # @return [Lib]
      def lib
        @@lib ||= new(lib_path)
      end

      # Sets the path to the VBoxXPCOMC library which is created with any
      # VirtualBox install. 90% of the time, this won't have to be set manually,
      # and instead the gem will try to find it for you.
      #
      # @param [String] Full path to the VBoxXPCOMC library
      def lib_path=(value)
        @@lib_path = value.nil? ? value : File.expand_path(value)
      end

      # Returns the path to the virtual box library. If the path
      # has not yet been set, it attempts to infer it based on the
      # platform ruby is running on.
      def lib_path
        if @@lib_path.nil?
          if Platform.mac?
            @@lib_path = Dir.glob("/Applications/{,MacPorts/}VirtualBox.app/Contents/MacOS/VBoxXPCOMC.dylib")
          elsif Platform.linux?
            @@lib_path = ["/opt/VirtualBox/VBoxXPCOMC.so", "/usr/lib/virtualbox/VBoxXPCOMC.so",
                          "/usr/lib64/virtualbox/VBoxXPCOMC.so"]
          elsif Platform.solaris?
            @@lib_path = ["/opt/VirtualBox/amd64/VBoxXPCOMC.so", "/opt/VirtualBox/i386/VBoxXPCOMC.so"]
          elsif Platform.freebsd?
            @@lib_path = ["/usr/local/lib/virtualbox/VBoxXPCOMC.so"]
          elsif Platform.windows?
            @@lib_path = "Unknown"
          else
            @@lib_path = "Unknown"
          end
        end

        @@lib_path
      end
    end

    def initialize(lib_path)
      if Platform.windows?
        @interface = COM::MSCOMInterface.new
      else
        @interface = COM::FFIInterface.create(lib_path)
      end

      @virtualbox = @interface.virtualbox
      @session = @interface.session
    end
  end
end
