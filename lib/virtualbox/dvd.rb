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
        Global.global.media.dvds
      end

      # Returns an array of all available DVDs by parsing the VBoxManage
      # output
      def all_from_command
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

      def populate_relationship(caller, doc)
        result = Proxies::Collection.new(caller)

        # TODO: Location in this case is relative the vboxconfig path.
        # We need to expand it. Also, size/accessible is not available.
        doc.css("MediaRegistry DVDImages Image").each do |hd_node|
          data = {}
          hd_node.attributes.each do |key, value|
            data[key.downcase.to_sym] = value.to_s
          end

          # Massage UUID to proper format
          data[:uuid] = data[:uuid][1..-2]

          result << new(data)
        end

        result
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
      Global.reload!
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end

    # Lazy load the lazy attributes for this model.
    def load_attribute(name)
      # Since the lazy attributes are related, we just load them all at once
      loaded_image = self.class.all_from_command.detect { |o| o.uuid == self.uuid }

      write_attribute(:accessible, loaded_image.accessible)
    end
  end
end