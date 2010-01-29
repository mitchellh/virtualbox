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
    def initialize(index, caller, data)
      super()
      
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
  end
end