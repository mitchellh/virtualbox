require 'virtualbox/abstract_model/attributable'
require 'virtualbox/abstract_model/dirty'
require 'virtualbox/abstract_model/relatable'

module VirtualBox
  # A VirtualBox model is an abtraction over the various data
  # items represented by a virtual machine. It allows the gem to
  # define fields on data items which are validated and later can 
  # be persisted. 
  class AbstractModel
    include Attributable
    include Dirty
    include Relatable
    
    def save(*args)
      # Go through changed attributes and call save_attribute for
      # those only
      changes.each do |key, values|
        save_attribute(key, values[1], *args)
      end

      save_relationships(*args)
    end
    
    def save_attribute(key, value, *args)
      clear_dirty!(key)
    end
    
    # Modify populate_attributes to not set dirtiness and also to
    # set relationships
    def populate_attributes(attribs)
      ignore_dirty do
        super
        
        populate_relationships(attribs)
      end
    end 
    
    # Modify write_attribute to set dirty for the dirty module
    def write_attribute(name, value)
      set_dirty!(name, read_attribute(name), value)
      super
    end
    
    def destroy(*args)
      # Destroy dependent relationships
      self.class.relationships.each do |name, options|
        destroy_relationship(name, *args) if options[:dependent] == :destroy
      end
    end
  end
end