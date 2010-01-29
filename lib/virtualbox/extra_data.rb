module VirtualBox
  # Represents "extra data" which can be set on a specific
  # virtual machine or on VirtualBox as a whole. Extra data is persistent
  # key-value storage which is available as a way to store any information
  # wanted. VirtualBox uses it for storing statistics and settings. You can
  # use it for anything!
  #
  # # Extra Data on a Virtual Machine
  #
  # Setting extra data on a virtual machine is easy. All {VM} objects have a 
  # `extra_data` relationship which is just a simple ruby hash, so you can treat
  # it like one! Once the data is set, simply saving the VM will save the
  # extra data. An example below:
  #
  #     vm = VirtualBox::VM.find("FooVM")
  #     vm.extra_data["ruby-accessed"]  = "yes, yes it was"
  #     vm.save
  #
  # Now, let's say you open up the VM again some other time:
  #
  #     vm = VirtualBox::VM.find("FooVM")
  #     puts vm.extra_data["ruby-accessed"]
  #
  # It acts just like a hash!
  #
  # # Global Extra Data
  #
  # Extra data doesn't need to be tied to a specific virtual machine. It can also
  # exist globally. Setting global extra-data is just as easy:
  #
  #     VirtualBox::ExtraData.global["some-key"] = "some value"
  #     VirtualBox::ExtraData.global.save
  #
  class ExtraData < Hash
    include AbstractModel::Dirty
    
    attr_accessor :parent
    
    class <<self
      # Gets the global extra data.
      #
      # @return [Array<ExtraData>]
      def global
        raw = Command.vboxmanage("getextradata global enumerate")
        parse_kv_pairs(raw)
      end
      
      # Parses the key-value pairs from the extra data enumerated
      # output.
      #
      # @param [String] raw The raw output from enumerating extra data.
      # @return [Hash]
      def parse_kv_pairs(raw, parent=nil)
        data = new(parent)
        raw.split("\n").each do |line|
          next unless line =~ /^Key: (.+?), Value: (.+?)$/i
          data[$1.to_s] = $2.strip.to_s
        end
        
        data.clear_dirty!
        data
      end
      
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<ExtraData>]
      def populate_relationship(caller, data)
        raw = Command.vboxmanage("getextradata #{Command.shell_escape(caller.name)} enumerate")
        parse_kv_pairs(raw, caller)
      end
      
      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, data)
        data.save
      end
    end
    
    # Initializes an extra data object. 
    #
    # @param [Hash] data Initial attributes to populate.
    def initialize(parent=nil)
      @parent = parent || "global"
    end
    
    # Set an extradata key-value pair. Overrides ruby hash implementation
    # to set dirty state. Otherwise that, behaves the same way.
    def []=(key,value)
      set_dirty!(key, self[key], value)
      super
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
    
    # Saves extra data. This method does the same thing for both new
    # and existing extra data, since virtualbox will overwrite old data or
    # create it if it doesn't exist.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def save(raise_errors=false)
      changes.each do |key, value|
        Command.vboxmanage("setextradata #{Command.shell_escape(parent_name)} #{Command.shell_escape(key)} #{Command.shell_escape(value[1])}")
        clear_dirty!(key)
      end
      
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
    def delete(key, raise_errors=false)
      Command.vboxmanage("setextradata #{Command.shell_escape(parent_name)} #{Command.shell_escape(key)}")
      super(key)
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
  end
end