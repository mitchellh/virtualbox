module VirtualBox
  module COM
    class FFIInterface
      extend ::FFI::Library

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

      class <<self
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
        initialize_com
      end

      # Initializes the COM interface with XPCOM. This sets up the `virtualbox`,
      # `session`, and `xpcom` attributes. This should only be called once.
      def initialize_com
        # Get the pointer to the XPCOMC struct which contains the functions
        # to initialize
        xpcom_pointer = self.class.VBoxGetXPCOMCFunctions(XPCOMC_VERSION)
        @xpcom = FFI::VBOXXPCOMC.new(xpcom_pointer)

        virtualbox_ptr = ::FFI::MemoryPointer.new(:pointer)
        session_ptr = ::FFI::MemoryPointer.new(:pointer)

        # Initialize the virtualbox API and get the global VirtualBox
        # interface and a session interface
        @xpcom[:pfnComInitialize].call(COM::Interface::VirtualBox::IID_STR, virtualbox_ptr, COM::Interface::Session::IID_STR, session_ptr)
        @virtualbox = Interface::VirtualBox.new(Implementer::FFI, self, virtualbox_ptr.get_pointer(0))
        @session = Interface::Session.new(Implementer::FFI, self, session_ptr.get_pointer(0))
      end
    end
  end
end