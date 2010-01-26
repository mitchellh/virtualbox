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
      
      # Returns an empty drive.
      def empty_drive
        new(:empty_drive)
      end
    end
    
    def initialize(*args)
      if args.length == 1 && args[0] == :empty_drive
        @empty_drive = true
      else
        super
      end
    end
    
    # Override of {Image#empty_drive?}. This will only be true if
    # the DVD was created with {DVD.empty_drive}.
    #
    # @return [Boolean]
    def empty_drive?
      @empty_drive || false
    end
    
    # Override of {Image#image_type}.
    def image_type
      "dvddrive"
    end
    
    # Deletes the DVD from VBox managed list and also from disk.
    # This method will fail if the disk is currently mounted to any
    # virtual machine.
    #
    # @return [Boolean]
    def destroy(raise_errors=false)
      return false if empty_drive?
      
      Command.vboxmanage("closemedium dvd #{uuid} --delete")
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
  end
end