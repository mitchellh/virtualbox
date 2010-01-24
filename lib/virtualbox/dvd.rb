module VirtualBox
  class DVD < Image
    class <<self
      # Returns an array of all available DVDs as DVD objects
      def all
        raw = Command.vboxmanage("list dvds")
        parse_raw(raw)
      end
    end
  end
end