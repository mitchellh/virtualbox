module VirtualBox
  module COM
    module Implementer
      autoload :Base, 'virtualbox/com/implementer/base'
      autoload :FFI, 'virtualbox/com/implementer/ffi'
      autoload :MSCOM, 'virtualbox/com/implementer/mscom'
      autoload :Nil, 'virtualbox/com/implementer/nil'
    end
  end
end
