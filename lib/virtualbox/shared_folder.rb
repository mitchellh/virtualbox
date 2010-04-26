module VirtualBox
  # Represents a shared folder in VirtualBox. In VirtualBox, shared folders are a
  # method for basically "symlinking" a folder on the guest system to a folder which
  # exists on the host system. This allows for sharing of files across the virtual
  # machine.
  #
  # **Note:** Whenever modifying shared folders on a VM, the changes won't take
  # effect until a _cold reboot_ occurs. This means actually closing the virtual
  # machine _completely_, then restarting it. You can't just hit "Start > Restart"
  # or do a `sudo reboot`. It doesn't work that way!
  #
  # # Getting Shared Folders
  #
  # All shared folders are attached to a {VM} object, by definition. Therefore, to
  # get a list of the shared folders, first {VM.find find} the VM you need, then
  # use the `shared_folders` relationship to access an array of the shared folders.
  # With this array, you can create, modify, update, and delete the shared folders
  # for that virtual machine.
  #
  # # Creating a Shared Folder
  #
  # **This whole section will assume you already looked up a {VM} and assigned it to
  # a local variable named `vm`.**
  #
  # With a VM found, creating a shared folder is just a few lines of code:
  #
  #     folder = VirtualBox::SharedFolder.new
  #     folder.name = "desktop-images"
  #     folder.hostpath = File.expand_path("~/Desktop/images")
  #     vm.shared_folders << folder
  #     folder.save # Or you can call vm.save, which works too!
  #
  # # Modifying an Existing Shared Folder
  #
  # **This whole section will assume you already looked up a {VM} and assigned it to
  # a local variable named `vm`.**
  #
  # Nothing tricky here: You treat existing shared folder objects just as if they
  # were new ones. Assign a new name and/or a new path, then save.
  #
  #     folder = vm.shared_folders.first
  #     folder.name = "rufus"
  #     folder.save # Or vm.save
  #
  # **Note**: The VirtualBox-saavy will know that VirtualBox doesn't actually
  # expose a way to edit shared folders. Under the hood, the virtualbox ruby
  # library is actually deleting the old shared folder, then creating a new
  # one with the new details. This shouldn't affect the way anything works for
  # the VM itself.
  #
  # # Deleting a Shared Folder
  #
  # **This whole section will assume you already looked up a {VM} and assigned it to
  # a local variable named `vm`.**
  #
  #     folder = vm.shared_folder.first
  #     folder.destroy
  #
  # Poof! It'll be gone. This is usually the place where I warn you about this
  # being non-reversable, but since no _data_ was actually destroyed, this is
  # not too risky. You could always just recreate the shared folder with the
  # same name and path and it'll be like nothing happened.
  #
  # # Attributes and Relationships
  #
  # Properties of the model are exposed using standard ruby instance
  # methods which are generated on the fly. Because of this, they are not listed
  # below as available instance methods.
  #
  # These attributes can be accessed and modified via standard ruby-style
  # `instance.attribute` and `instance.attribute=` methods. The attributes are
  # listed below.
  #
  # Relationships are also accessed like attributes but can't be set. Instead,
  # they are typically references to other objects such as an {AttachedDevice} which
  # in turn have their own attributes which can be modified.
  #
  # ## Attributes
  #
  # This is copied directly from the class header, but lists all available
  # attributes. If you don't understand what this means, read {Attributable}.
  #
  #     attribute :parent, :readonly => :readonly
  #     attribute :name
  #     attribute :hostpath
  #
  class SharedFolder < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :name
    attribute :host_path
    attribute :writable, :default => true, :boolean => true
    attribute :accessible, :readonly => true, :boolean => true

    class <<self
      # Populates the shared folder relationship for anything which is related to it.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<SharedFolder>]
      def populate_relationship(caller, imachine)
        relation = Proxies::Collection.new(caller)

        imachine.shared_folders.each do |ishared|
          relation << new(caller, ishared)
        end

        relation
      end

      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, items)
        items.each do |item|
          item.save
        end
      end
    end

    # @overload initialize(data={})
    #   Creates a new SharedFolder which is a new record. This
    #   should be attached to a VM and saved.
    #   @param [Hash] data (optional) A hash which contains initial attribute
    #     values for the SharedFolder.
    # @overload initialize(index, caller, data)
    #   Creates an SharedFolder for a relationship. **This should
    #   never be called except internally.**
    #   @param [Object] caller The parent
    #   @param [Hash] data A hash of data which must be used
    #     to extract the relationship data.
    def initialize(*args)
      super()

      if args.length == 2
        initialize_attributes(*args)
      end
    end

    # Initializes the attributes of an existing shared folder.
    def initialize_attributes(parent, ishared)
      # Set the parent
      write_attribute(:parent, parent)

      # Load the interface attributes
      load_interface_attributes(ishared)

      # Clear dirtiness, since this should only be called initially and
      # therefore shouldn't affect dirtiness
      clear_dirty!

      # But this is an existing record
      existing_record!
    end

    # Validates a shared folder.
    def validate
      super

      validates_presence_of :parent
      validates_presence_of :name
      validates_presence_of :host_path
    end

    # Saves or creates a shared folder.
    def save
      return true if !new_record? && !changed?
      raise Exceptions::ValidationFailedException.new(errors) if !valid?

      if !new_record?
        # If its not a new record, any changes will require a new shared
        # folder to be created, so we first destroy it then recreate it.
        destroy
      end

      create
    end

    # Creates a new shared folder. This method should not be called directly.
    # Instead, {save} should always be called, which will do the right thing.
    def create
      return unless new_record?

      parent.with_open_session do |session|
        machine = session.machine
        machine.create_shared_folder(name, host_path, writable)
      end

      existing_record!
      clear_dirty!
    end

    # Relationship callback when added to a collection. This is automatically
    # called by any relationship collection when this object is added.
    def added_to_relationship(parent)
      write_attribute(:parent, parent)
    end

    # Destroys the shared folder. This doesn't actually delete the folder
    # from the host system. Instead, it simply removes the mapping to the
    # virtual machine, meaning it will no longer be possible to mount it
    # from within the virtual machine.
    def destroy
      parent.with_open_session do |session|
        machine = session.machine
        machine.remove_shared_folder(name)
      end

      # Mark as a new record so if it is saved again, it will create it
      new_record!
   end
  end
end