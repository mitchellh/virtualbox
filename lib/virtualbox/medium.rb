module VirtualBox
  # Represents a medium object part of VirtualBox. A medium is a
  # hard drive, DVD, floppy disk, etc. Each of these share common
  # properties represented here.
  class Medium < AbstractModel
    include SubclassListing

    attribute :uuid, :readonly => true, :property => :id
    attribute :type, :readonly => true
    attribute :description, :readonly => true
    attribute :location, :readonly => true
    attribute :state, :readonly => true, :property => :refresh_state
    attribute :interface, :readonly => true, :property => false
    relationship :children, :Medium, :lazy => true

    class <<self
      # Populates a relationship with another model. Depending on the data sent
      # through as the `media` parameter, this can either return a single value
      # or an array of values. {Global}, for example, has a relationship of media,
      # while a {MediumAttachment} has a relationship with a single medium.
      #
      # **This method typically won't be used except internally.**
      def populate_relationship(caller, media)
        if media.is_a?(Array)
          # has many relationship
          populate_array_relationship(caller, media)
        else
          # has one relationship
          populate_single_relationship(caller, media)
        end
      end

      # Populates a relationship which has many media.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<Medium>]
      def populate_array_relationship(caller, media)
        relation = Proxies::Collection.new(caller)

        media.each do |medium|
          # Skip media this class isn't interested in
          next if device_type != :all && medium.device_type != device_type

          # Wrap it up and add to the relationship
          relation << new(medium)
        end

        relation
      end

      # Populates a relationship which has one medium. This method goes one step
      # further and instantiates the proper class for the type of medium given.
      # For example, given a `device_type` of `:hard_drive`, it would return a
      # {HardDrive} object.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Medium]
      def populate_single_relationship(caller, medium)
        return nil if medium.nil?

        subclasses.each do |subclass|
          # Skip this class unless the device type matches
          next unless subclass.device_type == medium.device_type

          # Wrap it up and return it
          return subclass.new(medium)
        end

        # If all else fails, just wrap it in a Medium
        new(medium)
      end

      # Specifies the device type that a {Medium} class is interested in. This
      # is `:all` on {Medium}, but is expected to be overridden by child classes.
      # The value returned should be one of {COM::Interface::DeviceType}.
      #
      # @return [Symbol]
      def device_type
        :all
      end
    end

    # Initializes a medium object, retrieving the attributes and information
    # from the {COM::Interface::Medium} object given as the parameter. This initialization
    # is done automatically by virtualbox when populating a relationship. Mediums should
    # never be initialized manually.
    #
    # @param [COM::Interface::Medium] imedium
    def initialize(imedium)
      write_attribute(:interface, imedium)
      initialize_attributes(imedium)
    end

    def initialize_attributes(imedium)
      # First refresh the state (required for many attributes)
      imedium.refresh_state

      # Load interface attributes
      load_interface_attributes(imedium)

      # Clear dirtiness, since this should only be called initially and
      # therefore shouldn't affect dirtiness
      clear_dirty!

      # But this is an existing record
      existing_record!
    end

    def load_relationship(name)
      # Populate children
      populate_relationship(name, interface.children)
    end

    # Returns the basename of the images location (the file name +extension)
    #
    # @return [String]
    def filename
      File.basename(location.to_s)
    end

    # Destroys the medium, optionally also phsyically destroying the backing
    # storage. This removes this medium from the VirtualBox media registry.
    # In order to remove the medium, it must not be attached to any virtual
    # machine. If it is, an exception of some sort will be raised.
    # This action happens *immediately* when the method is called, and is not
    # deferred to a save.
    def destroy(destroy_backing=false)
      if destroy_backing
        destroy_storage
      else
        interface.close
      end
    end

    # Destroys the backing store of the medium and the media registry. This is
    # analagous to calling {#destroy} with the first parameter set to true. This
    # method requires that the medium not be attached to any virtual machine
    # (running or not).
    def destroy_storage
      interface.delete_storage.wait_for_completion(-1)
    end
  end
end