module VirtualBox
  class Nic < AbstractModel
    attribute :parent, :readonly => :readonly
    attribute :nic
    attribute :type
    attribute :macaddress
    attribute :cableconnected
    attribute :bridgeadapter
    
    class <<self
      def populate_relationship(caller, data)
        relation = []
        
        counter = 1
        loop do
          break unless data["nic#{counter}".to_sym]
          nic = new(counter, caller, data)
          relation.push(nic)
          counter += 1
        end
        
        relation
      end
      
      def save_relationship(caller, data)
        # Just call save on each nic with the VM
        data.each do |nic|
          nic.save(caller.name)
        end
      end
    end
    
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
    
    def save_attribute(key, value, vmname)
      return if key == :type
      
      Command.vboxmanage("modifyvm #{vmname} --#{key}#{@index} #{Command.shell_escape(value)}")
      super
    end
  end
end