module VirtualBox
  # Represents a single NIC (Network Interface Card) of a virtual machine.
  #
  # **Currently, new NICs can't be created, so the only way to get this
  # object is through a {VM}'s `nics` relationship.**
  #
  # # Editing a NIC
  #
  # Nics can be modified directly in their relationship to other
  # virtual machines. When {VM#save} is called, it will also save any
  # changes to its relationships.
  #
  #     vm = VirtualBox::VM.find("foo")
  #     vm.nics[0].macaddress = @new_mac_address
  #     vm.save
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
  #     attribute :parent, :readonly => :readonly
  #     attribute :nic
  #     attribute :nictype
  #     attribute :macaddress
  #     attribute :cableconnected
  #     attribute :bridgeadapter
  #
  class Nic < AbstractModel
    attribute :parent, :readonly => :readonly
    attribute :nic
    attribute :nictype
    attribute :macaddress
    attribute :cableconnected
    attribute :bridgeadapter
    
    class <<self
      # Retrives the Nic data from human-readable vminfo. Since some data about
      # nics is not exposed in the machine-readable virtual machine info, some
      # extra parsing must be done to get these attributes. This method parses
      # the nic-specific data from this human readable information.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Hash]
      def nic_data(vmname)
        raw = VM.human_info(vmname)
        
        # Complicated chain of methods just maps parse_nic over each line,
        # removing invalid ones, and then converting it into a single hash.
        raw.split("\n").collect { |v| parse_nic(v) }.compact.inject({}) do |acc, obj|
          acc.merge({ obj[0] => obj[1] })
        end
      end
      
      # Parses nic data out of a single line of the human readable output
      # of vm info. 
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array] First element is nic name, second is data.
      def parse_nic(raw)
        return unless raw =~ /^NIC\s(\d):\s+(.+?)$/
        return if $2.to_s.strip == "disabled"
        
        data = {}
        nicname = "nic#{$1}"
        $2.to_s.split(/,\s+/).each do |raw_property|
          next unless raw_property =~ /^(.+?):\s+(.+?)$/
          
          data[$1.downcase.to_sym] = $2.to_s
        end
        
        return nicname.to_sym, data
      end
      
      # Populates the nic relationship for anything which is related to it.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<Nic>]
      def populate_relationship(caller, data)
        nic_data = nic_data(caller.name)
        
        relation = []
        
        counter = 1
        loop do
          break unless data["nic#{counter}".to_sym]
          
          nictype = nic_data["nic#{counter}".to_sym][:type] rescue nil
          
          nic = new(counter, caller, data.merge({
            "nictype#{counter}".to_sym => nictype
          }))
          relation.push(nic)
          counter += 1
        end
        
        relation
      end
      
      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, data)
        # Just call save on each nic with the VM
        data.each do |nic|
          nic.save(caller.name)
        end
      end
    end
    
    # Since there is currently no way to create a _new_ nic, this is 
    # only used internally. Developers should NOT try to initialize their
    # own nic objects.
    def initialize(index, caller, data)
      super()
      
      @index = index
      
      # Setup the index specific attributes
      populate_data = {}
      self.class.attributes.each do |name, options|
        value = data["#{name}#{index}".to_sym]
        populate_data[name] = value
      end
      
      populate_attributes(populate_data.merge({
        :parent => caller
      }))
    end
    
    # Saves a single attribute of the nic. This method is automatically
    # called on {#save}.
    #
    # **This method typically won't be used except internally.**
    def save_attribute(key, value, vmname)        
      Command.vboxmanage("modifyvm #{Command.shell_escape(vmname)} --#{key}#{@index} #{Command.shell_escape(value)}")
      super
    end
  end
end