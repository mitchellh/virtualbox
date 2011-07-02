require 'ffi'
require 'virtualbox/ext/logger'

module VirtualBox
  module COM
    class FFIInterface < BaseInterface
      extend ::FFI::Library
      include Logger

      # Constant used to initialize the XPCOM C interface
      XPCOMC_VERSION = 0x00020000

      # VBOXXPCOMC struct. This typically won't be used.
      attr_reader :xpcom

      # The VirtualBox and Session interfaces, both of which are extremely
      # important in interfacing with the VirtualBox API. Once these have been
      # initialized, all other parts of the API can be accessed via these
      # instances.
      attr_reader :virtualbox
      attr_reader :session

      class << self
        # Sets up the FFI interface and also initializes the interface,
        # returning an instance of {FFIInterface}.
        def create(lib_path=nil)
          setup(lib_path)
          new
        end

        # Sets up the FFI interface by specifying the FFI library path
        # and attaching the initial function (which can't be done until
        # the FFI library is specified).
        #
        # @param [String] lib_path
        def setup(lib_path=nil)
          # Setup the path to the C library
          lib_path ||= "/Applications/VirtualBox.app/Contents/MacOS/VBoxXPCOMC.dylib"

          # Attach to the interface
          ffi_lib lib_path
          attach_function :VBoxGetXPCOMCFunctions, [:uint], :pointer
        end
      end

      def initialize
        super
        initialize_com
      end

      # Initializes the COM interface with XPCOM. This sets up the `virtualbox`,
      # `session`, and `xpcom` attributes. This should only be called once.
      def initialize_com
        # Get the pointer to the XPCOMC struct which contains the functions
        # to initialize
        xpcom_pointer = self.class.VBoxGetXPCOMCFunctions(XPCOMC_VERSION)
        @xpcom = FFI::VBOXXPCOMC.new(xpcom_pointer)

        initialize_singletons
      end

      # Initializes the VirtualBox and Session interfaces. It goes through
      # the various directories until it finds a working pair.
      def initialize_singletons
        interface_dir = File.expand_path(File.join(File.dirname(__FILE__), "interface"))
        Dir[File.join(interface_dir, "*")].each do |f|
          if File.directory?(f)
            return if initialize_for_version(File.basename(f))
          end
        end
      end

      # Initializes the FFI interface for a specific version.
      def initialize_for_version(version)
        logger.debug("FFI init: Trying version #{version}")

        # Setup the FFI classes
        VirtualBox::COM::FFI.setup(version)
        virtualbox_klass = COM::Util.versioned_interface(:VirtualBox)
        session_klass = COM::Util.versioned_interface(:Session)

        # Setup the OUT pointers
        virtualbox_ptr = ::FFI::MemoryPointer.new(:pointer)
        session_ptr = ::FFI::MemoryPointer.new(:pointer)

        # Call the initialization functions
        @xpcom[:pfnComInitialize].call(virtualbox_klass::IID_STR, virtualbox_ptr, session_klass::IID_STR, session_ptr)
        @virtualbox = virtualbox_klass.new(Implementer::FFI, self, virtualbox_ptr.get_pointer(0))
        @session = session_klass.new(Implementer::FFI, self, session_ptr.get_pointer(0))

        # Make a call to version to verify no exceptions are raised
        @virtualbox.implementer.valid? && @session.implementer.valid?

        logger.debug("    -- Valid version")
        true
      rescue ::FFI::NullPointerError => e
        logger.debug("    -- Invalid version")
        false
      end
    end
  end
end
