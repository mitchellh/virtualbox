module VirtualBox
  # Represents a DVD image stored by VirtualBox. These DVD images can be
  # mounted onto virtual machines.
  #
  # # Finding all DVDs
  #
  # The only method at the moment of finding DVDs is to use {DVD.all}, which
  # returns an array of {DVD}s.
  #
  #     DVD.all
  #
  class DVD < Image
    class <<self
      # Returns an array of all available DVDs as DVD objects
      def all
        raw = Command.vboxmanage("list dvds")
        parse_raw(raw)
      end
    end
    
    # Deletes the DVD from VBox managed list and also from disk.
    # This method will fail if the disk is currently mounted to any
    # virtual machine.
    #
    # @return [Boolean]
    def destroy
      Command.vboxmanage("closemedium dvd #{uuid} --delete")
      return $?.to_i == 0
    end
  end
end