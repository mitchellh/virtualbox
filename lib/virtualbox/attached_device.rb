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
    attribute :uuid, :readonly => true
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
    
    # @overload initialize(data={})
    #   Creates a new AttachedDevice which is a new record. This
    #   should be attached to a storage controller and saved.
    #   @param [Hash] data (optional) A hash which contains initial attribute
    #     values for the AttachedDevice.
    # @overload initialize(index, caller, data)
    #   Creates an AttachedDevice for a relationship. **This should
    #   never be called except internally.**
    #   @param [Integer] index Index of the port
    #   @param [Object] caller The parent
    #   @param [Hash] data A hash of data which must be used
    #     to extract the relationship data.
    def initialize(*args)
      super()
      
      if args.length == 3
        populate_from_data(*args)
      elsif args.length == 1
        populate_attributes(*args)
        new_record!
      elsif args.empty?
        return
      else
        raise NoMethodError.new
      end
    end
    
    # Saves or creates an attached device. If this is a new record,
    # then {#create} will automatically be called a new record will be
    # created. Otherwise, nothing will happen since modifying existing
    # attached devices is not yet supported.
    def save(raise_errors=false)
      raise Exceptions::NoParentException.new if parent.nil?
      raise Exceptions::InvalidObjectException.new("Image must be set") if image.nil?
      
      # If the port changed, we have to destroy the old one, then create
      # a new one
      destroy(:port => port_was) if port_changed? && !port_was.nil?

      Command.vboxmanage("storageattach #{Command.shell_escape(parent.parent.name)} --storagectl #{Command.shell_escape(parent.name)} --port #{port} --device 0 --type #{image.image_type} --medium #{medium}")
      existing_record!
      clear_dirty!
      
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
    
    # Medium of the attached image. This attribute will be dependent
    # on the attached image and will return one of the following values:
    #
    # * **none** - There is no attached image
    # * **emptydrive** - An image with an empty drive is attached (see
    #     {DVD.empty_drive})
    # * **image uuid** - The image's UUID
    #
    # @return [String]
    def medium
      if image.nil?
        "none"
      elsif image.empty_drive?
        "emptydrive"
      else
        image.uuid
      end
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
      destroy_port = options[:port] || port
      Command.vboxmanage("storageattach #{Command.shell_escape(parent.parent.name)} --storagectl #{Command.shell_escape(parent.name)} --port #{destroy_port} --device 0 --medium none")      
      image.destroy if options[:destroy_image] && image
    end
    
    # Relationship callback when added to a collection. This is automatically
    # called by any relationship collection when this object is added.
    def added_to_relationship(parent)
      write_attribute(:parent, parent)
    end
    
    protected
    
    # Populates the model based on data from a parsed vminfo. This
    # method is used to create a model which already exists and is
    # part of a relationship.
    #
    # **This method should never be called except internally.**
    def populate_from_data(index, caller, data)
      populate_attributes({
        :parent => caller,
        :port => index,
        :medium => data["#{caller.name}-#{index}-0".downcase.to_sym],
        :uuid => data["#{caller.name}-ImageUUID-#{index}-0".downcase.to_sym]
      })
    end
  end
end
