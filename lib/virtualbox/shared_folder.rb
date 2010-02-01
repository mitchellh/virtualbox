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
    attribute :parent, :readonly => :readonly
    attribute :name, :populate_key => "SharedFolderNameMachineMapping"
    attribute :hostpath, :populate_key => "SharedFolderPathMachineMapping"

    class <<self
      # Populates the shared folder relationship for anything which is related to it.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<SharedFolder>]
      def populate_relationship(caller, data)
        relation = Proxies::Collection.new(caller)

        counter = 1
        loop do
          break unless data["SharedFolderNameMachineMapping#{counter}".downcase.to_sym]

          folder = new(counter, caller, data)
          relation.push(folder)
          counter += 1
        end

        relation
      end

      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, data)
        # Just call save on each folder with the VM
        data.each do |sf|
          sf.save
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
    #   @param [Integer] index Index of the shared folder
    #   @param [Object] caller The parent
    #   @param [Hash] data A hash of data which must be used
    #     to extract the relationship data.
    def initialize(*args)
      super()

      if args.length == 3
        initialize_for_relationship(*args)
      elsif args.length == 1
        initialize_for_data(*args)
      elsif args.length == 0
        return
      else
        raise NoMethodError.new
      end
    end

    # Initializes the record for use in a relationship. This
    # is automatically called by {#initialize} if it has three
    # parameters.
    #
    # **This method typically won't be used except internally.**
    def initialize_for_relationship(index, caller, data)
      # Setup the index specific attributes
      populate_data = {}
      self.class.attributes.each do |name, options|
        key = options[:populate_key] || name
        value = data["#{key}#{index}".downcase.to_sym]
        populate_data[key] = value
      end

      populate_attributes(populate_data.merge({
        :parent => caller
      }))
    end

    # Initializes a record with initial data but keeping it a "new
    # record." This is called automatically if {#initialize} is given
    # only a single parameter. View {#initialize} for documentation.
    def initialize_for_data(data)
      self.class.attributes.each do |name, options|
        data[options[:populate_key]] = data[name]
      end

      populate_attributes(data)
      new_record!
    end

    # Validates a shared folder.
    def validate
      super

      validates_presence_of :parent
      validates_presence_of :name
      validates_presence_of :hostpath
    end

    # Saves or creates a shared folder.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def save(raise_errors=false)
      return true unless changed?

      if !valid?
        raise Exceptions::ValidationFailedException.new(errors) if raise_errors
        return false
      end

      # If this isn't a new record, we destroy it first
      destroy(raise_errors) if !new_record?

      Command.vboxmanage("sharedfolder", "add", parent.name, "--name", name, "--hostpath", hostpath)
      existing_record!
      clear_dirty!

      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
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
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def destroy(raise_errors=false)
      # If the name changed, we have to be sure to use the previous
      # one.
      name_value = name_changed? ? name_was : name

      Command.vboxmanage("sharedfolder", "remove", parent.name, "--name", name_value)
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
  end
end