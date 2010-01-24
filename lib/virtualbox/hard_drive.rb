module VirtualBox
  class HardDrive < Image
    attribute :format, :readonly => true
    
    class <<self
      # Returns an array of all available hard drives as HardDrive
      # objects
      def all
        raw = Command.vboxmanage("list hdds")
        parse_raw(raw)
      end
    end
  end
end