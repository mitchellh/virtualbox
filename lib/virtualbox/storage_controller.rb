module VirtualBox
  # Represents a single storage controller which can be attached to a
  # virtual machine.
  # 
  # **Currently, storage controllers can not be created from scratch.
  # Therefore, the only way to use this model is through a relationship
  # of a {VM} object.**
  #
  # # Attributes and Relationships
  #
  # Properties of the storage controller are exposed using standard ruby instance
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
  #     attribute :name
  #     attribute :type
  #     attribute :max_ports, :populate_key => :maxportcount
  #     attribute :ports, :populate_key => :portcount
  #
  # ## Relationships
  #
  # In addition to the basic attributes, a virtual machine is related
  # to other things. The relationships are listed below. If you don't
  # understand this, read {Relatable}.
  #
  #     relationship :devices, AttachedDevice, :dependent => :destroy
  #
  class StorageController < AbstractModel
    attribute :parent, :readonly => true
    attribute :name
    attribute :type
    attribute :max_ports, :populate_key => :maxportcount
    attribute :ports, :populate_key => :portcount
    relationship :devices, AttachedDevice, :dependent => :destroy
    
    class <<self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<StorageController>]
      def populate_relationship(caller, data)
        relation = []
        
        counter = 0
        loop do
          break unless data["storagecontrollername#{counter}".to_sym]
          nic = new(counter, caller, data)
          relation.push(nic)
          counter += 1
        end
        
        relation
      end
      
      # Destroys a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      def destroy_relationship(caller, data, *args)
        data.each { |v| v.destroy(*args) }
      end
      
      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, data)
        # Just call save on each nic with the VM
        data.each do |sc|
          sc.save
        end
      end
    end
    
    # Since storage controllers still can't be created from scratch,
    # this method shouldn't be called. Instead, storage controllers
    # can be retrieved through relationships of other models such
    # as {VM}.
    def initialize(index, caller, data)
      super()
      
      @index = index
      
      # Setup the index specific attributes
      populate_data = {}
      self.class.attributes.each do |name, options|
        key = options[:populate_key] || name
        value = data["storagecontroller#{key}#{index}".to_sym]
        populate_data[key] = value
      end
      
      # Make sure to merge in device data so those relationships will be
      # setup properly
      populate_data.merge!(extract_devices(index, data))
      
      populate_attributes(populate_data.merge({
        :parent => caller
      }))
    end
    
    # Extracts related devices for a storage controller.
    #
    # **This method typically won't be used except internally.**
    #
    # @return [Hash]
    def extract_devices(index, data)
      name = data["storagecontrollername#{index}".downcase.to_sym].downcase
      
      device_data = {}
      data.each do |k,v|
        next unless k.to_s =~ /^#{name}-/
        
        device_data[k] = v
      end
      
      device_data
    end
  end
end