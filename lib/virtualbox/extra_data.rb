module VirtualBox
  # Represents "extra data" which can be set on a specific
  # virtual machine or on VirtualBox as a whole.
  class ExtraData < AbstractModel
    attribute :parent, :default => "global"
    attribute :key
    attribute :value
    
    class <<self
      # Gets the global extra data.
      #
      # @return [Array<ExtraData>]
      def global
        raw = Command.vboxmanage("getextradata global enumerate")
        pairs_to_objects(parse_kv_pairs(raw))
      end
      
      # Converts the key-value pairs to ExtraData objects.
      #
      # @param [Hash] pairs ExtraData key-value pair as ruby hash.
      # @return [Array<ExtraData>]
      def pairs_to_objects(pairs, other_data={})
        objects = []
        
        pairs.keys.sort.each do |k|
          v = pairs[k]
          objects.push(new({
            :key    => k,
            :value  => v
          }.merge(other_data)))
        end
        
        objects
      end
      
      # Parses the key-value pairs from the extra data enumerated
      # output.
      #
      # @param [String] raw The raw output from enumerating extra data.
      # @return [Hash]
      def parse_kv_pairs(raw)
        data = {}
        raw.lines.each do |line|
          next unless line =~ /^Key: (.+?), Value: (.+?)$/i
          data[$1.to_s] = $2.strip.to_s
        end
        
        data
      end
      
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<ExtraData>]
      def populate_relationship(caller, data)
        raw = Command.vboxmanage("getextradata #{Command.shell_escape(caller.name)} enumerate")
        pairs_to_objects(parse_kv_pairs(raw), {
          :parent => caller
        })
      end
      
      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, data)
        data.each do |ed|
          ed.save
        end
      end
    end
    
    # Initializes an extra data object. 
    #
    # @param [Hash] data Initial attributes to populate.
    def initialize(data)
      super()
      populate_attributes(data)
    end
    
    # Special accessor for parent name attribute. This returns
    # either the parent name if its a VM object, otherwise
    # just returns the default.
    #
    # @return [String]
    def parent_name
      if parent.is_a?(VM)
        parent.name
      else
        parent
      end
    end
    
    # Relationship callback when added to a collection. This is automatically
    # called by any relationship collection when this object is added.
    def added_to_relationship(parent)
      write_attribute(:parent, parent)
    end
    
    # Validates extra data.
    def validate
      super
      
      validates_presence_of :parent
      validates_presence_of :key
      validates_presence_of :value
    end
    
    # Saves extra data. This method does the same thing for both new
    # and existing extra data, since virtualbox will overwrite old data or
    # create it if it doesn't exist.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def save(raise_errors=false)
      if !valid?
        raise Exceptions::ValidationFailedException.new(errors) if raise_errors
        return false
      end
      
      destroy(raise_errors) if key_changed?
      Command.vboxmanage("setextradata #{Command.shell_escape(parent_name)} #{Command.shell_escape(key)} #{Command.shell_escape(value)}")
      clear_dirty!
      
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
    
    # Deletes the extra data. 
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def destroy(raise_errors=false)
      delete_key = key_changed? ? key_was : key
      Command.vboxmanage("setextradata #{Command.shell_escape(parent_name)} #{Command.shell_escape(delete_key)}")
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
  end
end