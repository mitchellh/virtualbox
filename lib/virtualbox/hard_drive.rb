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
  # Or use find with the UUID of the HardDrive:
  #
  #     VirtualBox::HardDrive.find("4a896f0b-b3a3-4dec-8c26-8406c6fccd6e")
  #
  # # Creating a Hard Drive
  #
  # Hard Drives can be created by intilizing an empty hard drive, assigning
  # values to the necessary attributes, and calling save on the object.
  # Below is a simple example of how this works:
  #
  #     hd = VirtualBox::HardDrive.new
  #     hd.format = "VDI" # Or any format list with `VBoxManage list hddbackends`
  #     hd.location = "foo.vdi"
  #     hd.size = 2400 # in megabytes
  #     hd.save
  #
  #     # You can now access other attributes, since its saved:
  #     hd.uuid
  #     hd.location # will return a full path now
  #
  # # Destroying Hard Drives
  #
  # Hard drives can also be deleted. **This operation is not reversable**.
  #
  #     hd = VirtualBox::HardDrive.find("...")
  #     hd.destroy
  #
  # This will only unregister the Hard Drive from VirtualBox and will not destroy
  # the storage space on the disk. To destroy the storage space, pass `true` to
  # the destroy method, example:
  #
  #     hd.destroy(true)
  #
  # # Cloning Hard Drives
  #
  # Hard Drives can just as easily be cloned as they can be created or destroyed.
  #
  #     hd = VirtualBox::HardDrive.find("...")
  #     cloned_hd = hd.clone("bar.vdi")
  #
  # In addition to simply cloning hard drives, this command can be used to
  # clone to a different format. If the format is not passed in (as with the
  # the above example, the system default format will be used). example:
  #
  #     hd = VirtualBox::HardDrive.find("...")
  #     hd.clone("bar.vmdk", "VMDK") # Will clone and convert to VMDK format
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
  #     attribute :format, :default => "VDI"
  #     attribute :location
  #     attribute :logical_size
  #     attribute :physical_size, :readonly => true, :property => :size
  #
  # There are more attributes on the {Medium} model, which {HardDrive} inherits
  # from.
  #
  class HardDrive < Medium
    include ByteNormalizer

    attribute :format, :default => "VDI"
    attribute :location
    attribute :logical_size
    attribute :physical_size, :readonly => true, :property => :size

    class <<self
      # Returns an array of all available hard drives as HardDrive
      # objects.
      #
      # @return [Array<HardDrive>]
      def all
        Global.global(true).media.hard_drives
      end

      # Finds one specific hard drive by UUID. If the hard drive
      # can not be found, will return `nil`.
      #
      # @param [String] id The UUID of the hard drive
      # @return [HardDrive]
      def find(id)
        all.detect { |hd| hd.uuid == id }
      end

      # Override of {Medium.device_type}.
      def device_type
        :hard_disk
      end
    end

    # Overwrite the AbstractModel initialize to make the imedium parameter
    # optional so that new Hard Drives can be created
    def initialize(imedium = nil)
      super if imedium
    end

    # Custom getter to convert the physical size from bytes to megabytes.
    def physical_size
      bytes_to_megabytes(read_attribute(:physical_size))
    end

    # Get an array of machines attached to this Virtual Machine
    def machines
      interface.machine_ids.collect { |id| VirtualBox::VM.find(id) }
    end

    # Validates a hard drive for the minimum attributes required to
    # create or save.
    def validate
      super

      medium_formats = Global.global.system_properties.medium_formats.collect { |mf| mf.id }
      validates_inclusion_of :format, :in => medium_formats, :message => "must be one of the following: #{medium_formats.join(', ')}."

      validates_presence_of :location

      max_vdi_size = Global.global.system_properties.max_vdi_size
      validates_inclusion_of :logical_size, :in => (0..max_vdi_size), :message => "must be between 0 and #{max_vdi_size}."
    end

    # Creates a new {COM::Interface::Medium} instance. This simply creates
    # the new {COM::Interface::Medium} structure. It does not (and shouldn't)
    # create the storage space on the host system. See the create method for
    # an example on to create the storage space.
    #
    # @param [String] outputfile The output file. This can be a full path
    #   or just a filename. If its just a filename, it will be placed in
    #   the default hard drives directory. Should not be present already.
    # @param [String] format The format to convert to. If not present, the
    #   systems default will be used.
    # @return [COM::Interface::Medium] The new {COM::Interface::Medium} instance
    #   or will raise a {Exceptions::MediumCreationFailedException} on failure.
    def create_hard_disk_medium(outputfile, format = nil)
      # Get main VirtualBox object
      virtualbox = Lib.lib.virtualbox

      # Assign the default format if it isn't set yet
      format ||= virtualbox.system_properties.default_hard_disk_format

      # Expand path relative to the default hard disk folder. This allows
      # filenames to exist in the default folder while full paths will use
      # the paths specified.
      outputfile = File.expand_path(outputfile, virtualbox.system_properties.default_hard_disk_folder)

      # If the outputfile path is in use by another Hard Drive, lets fail
      # now with a meaningful exception rather than simply return a nil
      raise Exceptions::MediumLocationInUseException.new(outputfile) if File.exist?(outputfile)

      # Create the new {COM::Interface::Medium} instance.
      new_medium = virtualbox.create_hard_disk(format, outputfile)

      # Raise an error if the creation of the {COM::Interface::Medium}
      # instance failed
      raise Exceptions::MediumCreationFailedException.new unless new_medium

      # Return the new {COM::Interface::Medium} instance.
      new_medium
    end

    # Clone hard drive, possibly also converting formats. All formats
    # supported by your local VirtualBox installation are supported
    # here. If no format is specified, the systems default will be used.
    #
    # @param [String] outputfile The output file. This can be a full path
    #   or just a filename. If its just a filename, it will be placed in
    #   the default hard drives directory. Should not be present already.
    # @param [String] format The format to convert to. If not present, the
    #   systems default will be used.
    # @return [HardDrive] The new, cloned hard drive, or nil on failure.
    def clone(outputfile, format = nil)
      # Create the new Hard Disk medium
      new_medium = create_hard_disk_medium(outputfile, format)

      # Clone the current drive onto the new Hard Disk medium
      interface.clone_to(new_medium, :standard, nil).wait_for_completion(-1)

      # Locate the newly cloned hard drive
      self.class.find(new_medium.id) if new_medium.respond_to?(:id)
    end

    # Creates a new hard drive.
    #
    # **This method should NEVER be called. Call {#save} instead.**
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def create
      return false unless new_record?
      raise Exceptions::ValidationFailedException.new(errors) if !valid?

      # Create the new Hard Disk medium
      new_medium = create_hard_disk_medium(location, format)

      # Create the storage on the host system
      new_medium.create_base_storage(logical_size, :standard).wait_for_completion(-1)

      # Update the current Hard Drive instance with the uuid and
      # other attributes assigned after storage was written
      write_attribute(:interface, new_medium)
      initialize_attributes(new_medium)

      # If the uuid is present, then everything worked
      uuid && !uuid.to_s.empty?
    end

    # Saves the hard drive object. If the hard drive is new,
    # this will create a new hard drive. Otherwise, it will
    # save any other details about the existing hard drive.
    #
    # Currently, **saving existing hard drives does nothing**.
    # This is a limitation of VirtualBox, rather than the library itself.
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def save
      return true if !new_record? && !changed?
      raise Exceptions::ValidationFailedException.new(errors) if !valid?

      if new_record?
        create # Create a new hard drive
      else
        # Mediums like Hard Drives are not updatable, they need to be recreated
        # Because Hard Drives contain info and paritions, it's easier to error
        # out now than try and do some complicated logic
        msg = "Hard Drives cannot be updated. You need to create one from scratch."
        raise Exceptions::MediumNotUpdatableException.new(msg)
      end
    end
  end
end
