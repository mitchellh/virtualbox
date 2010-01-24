module VirtualBox
  class AttachedDevice < AbstractModel
    attribute :parent, :readonly => true
    attribute :uuid
    attribute :medium
    attribute :port
    relationship :image, Image
    
    class <<self
      def populate_relationship(caller, data)
        relation = []
        
        counter = 0
        loop do
          break unless data["#{caller.name}-#{counter}-0".downcase.to_sym]
          nic = new(counter, caller, data)
          relation.push(nic)
          counter += 1
        end
        
        relation
      end
      
      def save_relationship(caller, data)
      end
    end
    
    def initialize(index, caller, data)
      super()
      
      populate_attributes({
        :parent => caller,
        :port => index,
        :medium => data["#{caller.name}-#{index}-0".downcase.to_sym],
        :uuid => data["#{caller.name}-ImageUUID-#{index}-0".downcase.to_sym]
      })
    end
    
    def destroy(destroy_image=false)
      # parent = storagecontroller
      # parent.parent = vm
      Command.vboxmanage("storageattach #{Command.shell_escape(parent.parent.name)} --storagectl #{Command.shell_escape(parent.name)} --port #{port} --device 0 --medium none")      
      image.destroy if destroy_image && image
    end
  end
end
