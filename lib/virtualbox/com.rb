module VirtualBox
  module COM
    WSTRING = :unicode_string
    T_INT8 = :int8
    T_UINT8 = :uint8
    T_INT32 = :int
    T_INT64 = :long
    T_UINT16 = :ushort
    T_UINT32 = :uint
    T_UINT64 = :ulong
    T_BOOL = :char

    autoload :AbstractEnum, 'virtualbox/com/abstract_enum'
    autoload :AbstractImplementer, 'virtualbox/com/abstract_implementer'
    autoload :AbstractInterface, 'virtualbox/com/abstract_interface'
    autoload :BaseInterface, 'virtualbox/com/base_interface'
    autoload :FFI, 'virtualbox/com/ffi'
    autoload :FFIInterface, 'virtualbox/com/ffi_interface'
    autoload :Implementer, 'virtualbox/com/implementer'
    autoload :MSCOMInterface, 'virtualbox/com/mscom_interface'
    autoload :NilInterface, 'virtualbox/com/nil_interface'
    autoload :Util, 'virtualbox/com/util'
  end
end
