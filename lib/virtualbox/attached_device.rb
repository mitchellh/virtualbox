module VirtualBox
  # Represents an device which is attached to a storage controller. An example
  # of such a device would be a CD or hard drive attached to an IDE controller.
  #
  # **Currently, attached devices can not be created from scratch. The only way
  # to access them is through relationships with other models such as
  # {StorageController}.**
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
  #     attribute :parent, :readonly => true
  #     attribute :uuid
  #     attribute :medium
  #     attribute :port
  #
  # ## Relationships
  #
  # In addition to the basic attributes, a virtual machine is related
  # to other things. The relationships are listed below. If you don't
  # understand this, read {Relatable}.
  #
  #     relationship :image, Image
  #
  class AttachedDevice < AbstractModel
    attribute :parent, :readonly => true
    attribute :uuid
    attribute :medium
    attribute :port
    relationship :image, Image
    
    class <<self
      # Populate relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<AttachedDevice>]
      def populate_relationship(caller, data)
        relation = Proxies::Collection.new(caller)
        
        counter = 0
        loop do
          break unless data["#{caller.name}-#{counter}-0".downcase.to_sym]
          nic = new(counter, caller, data)
          relation.push(nic)
          counter += 1
        end
        
        relation
      end
      
      # Destroy attached devices associated with another model.
      #
      # **This method typically won't be used except internally.**
      def destroy_relationship(caller, data, *args)
        data.each { |v| v.destroy(*args) }
      end
    end
    
    # Since attached devices can not be created from scratch yet, this
    # method should never be called. Instead access attached devices
    # through relationships from other models such as {StorageController}.
    def initialize(index, caller, data)
      super()
      
      populate_attributes({
        :parent => caller,
        :port => index,
        :medium => data["#{caller.name}-#{index}-0".downcase.to_sym],
        :uuid => data["#{caller.name}-ImageUUID-#{index}-0".downcase.to_sym]
      })
    end
    
    # Destroys the attached device. By default, this only removes any
    # media inserted within the device, but does not destroy it. This
    # option can be specified, however, through the `destroy_image`
    # option.
    #
    # @option options [Boolean] :destroy_image (false) If true, will also
    #   destroy the image associated with device.
    def destroy(options={})
      # parent = storagecontroller
      # parent.parent = vm
      Command.vboxmanage("storageattach #{Command.shell_escape(parent.parent.name)} --storagectl #{Command.shell_escape(parent.name)} --port #{port} --device 0 --medium none")      
      image.destroy if options[:destroy_image] && image
    end
  end
end
