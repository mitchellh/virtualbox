module VirtualBox
  class DVD < Image
    class <<self
      # Returns an array of all available DVDs as DVD objects
      def all
        raw = Command.vboxmanage("list dvds")
        parse_raw(raw)
      end
    end
    
    # Deletes the DVD from VBox managed list, but not actually from
    # disk itself.
    def destroy
      Command.vboxmanage("closemedium dvd #{uuid} --delete")
      return $?.to_i == 0
    end
  end
end