module VirtualBox
  # Represents a shared folder in VirtualBox.
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
        relation = []
        
        counter = 1
        loop do
          break unless data["SharedFolderNameMachineMapping#{counter}".downcase.to_sym]
          
          folder = new(counter, caller, data)
          relation.push(folder)
          counter += 1
        end
        
        relation
      end
    end
    
    # Since there is currently no way to create a _new_ shared folder, this is 
    # only used internally. Developers should NOT try to initialize their
    # own shared folder objects.
    def initialize(*args)
      super()
      
      if args.length == 3
        initialize_for_relationship(*args)
      elsif args.length <= 1
        return
      else
        raise NoMethodError.new
      end
    end
    
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
      
      Command.vboxmanage("sharedfolder add #{Command.shell_escape(parent.name)} --name #{Command.shell_escape(name)} --hostpath #{Command.shell_escape(hostpath)}")
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
      
      Command.vboxmanage("sharedfolder remove #{Command.shell_escape(parent.name)} --name #{Command.shell_escape(name_value)}")
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
  end
end