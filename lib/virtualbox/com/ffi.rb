require 'ffi'

module VirtualBox
  module COM
    module FFI
      autoload :Interface, 'virtualbox/com/ffi/interface'
      autoload :Util, 'virtualbox/com/ffi/util'

      extend ::FFI::Library

      # Callback types for VBOXXPCOMC
      callback :pfnGetVersion, [], :uint
      callback :pfnComInitialize, [:string, :pointer, :string, :pointer], :void
      callback :pfnComUninitialize, [], :void
      callback :pfnComUnallocMem, [:pointer], :void
      callback :pfnUtf16Free, [:pointer], :void
      callback :pfnUtf8Free, [:string], :void
      callback :pfnUtf16ToUtf8, [:pointer, :pointer], :int
      callback :pfnUtf8ToUtf16, [:string, :pointer], :int
      callback :pfnGetEventQueue, [:pointer], :void

      class VBOXXPCOMC < ::FFI::Struct
        layout  :cb, :uint,
                :uVersion, :uint,
                :pfnGetVersion, :pfnGetVersion,
                :pfnComInitialize, :pfnComInitialize,
                :pfnComUninitialize, :pfnComUninitialize,
                :pfnComUnallocMem, :pfnComUnallocMem,
                :pfnUtf16Free, :pfnUtf16Free,
                :pfnUtf8Free, :pfnUtf8Free,
                :pfnUtf16ToUtf8, :pfnUtf16ToUtf8,
                :pfnUtf8ToUtf16, :pfnUtf8ToUtf16,
                :pfnGetEventQueue, :pfnGetEventQueue,
                :uEndVersion, :uint
      end
    end
  end
end
