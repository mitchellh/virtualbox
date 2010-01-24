module VirtualBox
  class Nic < AbstractModel
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
          nic = new(counter, data)
          relation.push(nic)
          counter += 1
        end
        
        relation
      end
      
      def save_relationship(caller, data)
      end
    end
    
    def initialize(index, data)
      super()
      
      @index = index
      
      # Setup the index specific attributes
      populate_data = {}
      self.class.attributes.each do |name, options|
        value = data["#{name}#{index}".to_sym]
        populate_data[name] = value
      end
      
      populate_attributes(populate_data)
    end
  end
end