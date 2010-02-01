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
  # # Empty Drives
  #
  # Sometimes it is useful to have an empty drive. This is the case where you
  # may have a DVD drive but it has no disk in it. To create an {AttachedDevice},
  # an image _must_ be specified, and an empty drive is a simple option. Creating
  # an empty drive is simple:
  #
  #     DVD.empty_drive
  #
  class DVD < Image
    class <<self
      # Returns an array of all available DVDs as DVD objects
      def all
        raw = Command.vboxmanage("list", "dvds")
        parse_raw(raw)
      end

      # Returns an empty drive. This is useful for creating new
      # or modifyingn existing {AttachedDevice} objects and
      # attaching an empty drive to them.
      #
      # @return [DVD]
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
    # virtual machine. This method also does nothing for empty drives
    # (see {DVD.empty_drive}) and will return false automatically in
    # that case.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def destroy(raise_errors=false)
      return false if empty_drive?

      Command.vboxmanage("closemedium", "dvd", uuid, "--delete")
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
  end
end