module VirtualBox
  # Represents a hard disk which is registered with VirtualBox.
  #
  # # Finding a Hard Drive
  #
  # Hard drives can be found use {HardDrive.all} and {HardDrive.find}, which
  # find all or a specific hard drive, respectively. Example below:
  #
  #     VirtualBox::HardDrive.all
  # 
  # Or:
  #
  #     VirtualBox::HardDrive.find("Foo.vdi")
  #
  # # Creating a Hard Drive
  #
  # The hard drive is one of the few data items at the moment which supports
  # new creation. Below is a simple example of how this works:
  #
  #     hd = VirtualBox::HardDrive.new
  #     hd.location = "foo.vdi"
  #     hd.size = 2400 # in megabytes
  #     hd.save
  #
  #     # You can now access other attributes, since its saved:
  #     hd.uuid
  #     hd.location # will return a full path now
  #
  # Although `VDI` is the default format for newly created hard drives, other
  # formats are supported:
  #
  #     hd = VirtualBox::HardDrive.new
  #     hd.format = "VMDK"
  #     hd.location = "bar.vmdk"
  #     hd.size = 9001 # Its over 9000! (If you don't understand the reference, just ignore this comment)
  #     hd.save
  #
  # Any formats listed by your VirtualBox installation's `VBoxManage list hddbackends` command
  # can be used with the virtualbox gem.
  #
  # # Destroying Hard Drives
  #
  # Hard drives can also be deleted, which will completely remove them from
  # disk. **This operation is not reversable**.
  #
  #     hd = VirtualBox::HardDrive.find("foo")
  #     hd.destroy
  #
  # # Cloning Hard Drives
  #
  # Hard drives can just as easily be cloned as they can be created or destroyed.
  # 
  #     hd = VirtualBox::HardDrive.find("foo")
  #     cloned_hd = hd.clone("bar") 
  #
  # In addition to simply cloning hard drives, this command can be used to
  # clone to a different format:
  #
  #     hd = VirtualBox::HardDrive.find("foo")
  #     hd.clone("bar", "VMDK") # Will clone and convert to VMDK format
  #
  # # Attributes
  #
  # Properties of the model are exposed using standard ruby instance
  # methods which are generated on the fly. Because of this, they are not listed
  # below as available instance methods. 
  #
  # These attributes can be accessed and modified via standard ruby-style
  # `instance.attribute` and `instance.attribute=` methods. The attributes are
  # listed below. If you aren't sure what this means or you can't understand
  # why the below is listed, please read {Attributable}.
  # 
  #     attribute :uuid, :readonly => true
  #     attribute :location
  #     attribute :accessible, :readonly => true
  #     attribute :format, :default => "VDI"
  #     attribute :size
  #
  class HardDrive < Image
    attribute :format, :default => "VDI"
    attribute :size
    
    class <<self
      # Returns an array of all available hard drives as HardDrive
      # objects.
      #
      # @return [Array<HardDrive>]
      def all
        raw = Command.vboxmanage("list hdds")
        parse_blocks(raw).collect { |v| find(v[:uuid]) }
      end
      
      # Finds one specific hard drive by UUID or file name. If the
      # hard drive can not be found, will return `nil`.
      #
      # @return [HardDrive]
      def find(id)
        raw = Command.vboxmanage("showhdinfo #{id}")
        
        # Return nil if the hard drive doesn't exist
        return nil if raw =~ /VERR_FILE_NOT_FOUND/
        
        data = raw.split(/\n\n/).collect { |v| parse_block(v) }.find { |v| !v.nil? }
        
        # Set equivalent fields
        data[:format] = data[:"storage format"]
        data[:size] = data[:"logical size"].split(/\s+/)[0] if data.has_key?(:"logical size")
        
        # Return new object
        new(data)
      end
    end
    
    # Clone hard drive, possibly also converting formats. All formats
    # supported by your local VirtualBox installation are supported 
    # here. If no format is specified, the format of the source drive
    # will be used.
    #
    # @param [String] outputfile The output file. This should be just a
    #   single filename, since VirtualBox will place it in the hard
    #   drives folder.
    # @param [String] format The format to convert to.
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [HardDrive] The new, cloned hard drive, or nil on failure.
    def clone(outputfile, format="VDI", raise_errors=false)
      raw = Command.vboxmanage("clonehd #{uuid} #{Command.shell_escape(outputfile)} --format #{format} --remember")
      return nil unless raw =~ /UUID: (.+?)$/
      
      self.class.find($1.to_s)
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      nil
    end
    
    # Override of {Image#image_type}.
    def image_type
      "hdd"
    end
    
    # Creates a new hard drive. 
    #
    # **This method should NEVER be called. Call {#save} instead.**
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def create(raise_errors=false)
      raw = Command.vboxmanage("createhd --filename #{location} --size #{size} --format #{read_attribute(:format)} --remember")
      return nil unless raw =~ /UUID: (.+?)$/
      
      # Just replace our attributes with the newly created ones. This also
      # will set new_record to false.
      populate_attributes(self.class.find($1.to_s).attributes)
      
      # Return the success of the command
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
    
    # Saves the hard drive object. If the hard drive is new,
    # this will create a new hard drive. Otherwise, it will
    # save any other details about the existing hard drive.
    # 
    # Currently, **saving existing hard drives does nothing**.
    # This is a limitation of VirtualBox, rather than the library itself.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def save(raise_errors=false)
      if new_record?
        # Create a new hard drive
        create(raise_errors)
      else
        super
      end
    end
    
    # Destroys the hard drive. This deletes the hard drive off
    # of disk. 
    # 
    # **This operation is not reversable.**
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def destroy(raise_errors=false)
      Command.vboxmanage("closemedium disk #{uuid} --delete")
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
  end
end