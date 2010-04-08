module VirtualBox
  module COM
    class Util
      class <<self
        # Returns a boolean true/false whether the given COM interface
        # exists.
        #
        # @return [Boolean]
        def interface?(name)
          COM::Interface.const_get(name.to_sym)
          true
        rescue NameError
          false
        end
      end
    end
  end
end