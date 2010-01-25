require 'virtualbox/abstract_model/attributable'
require 'virtualbox/abstract_model/dirty'
require 'virtualbox/abstract_model/relatable'

module VirtualBox
  # AbstractModel is the base class used for most of virtualbox's classes.
  # It provides convenient ActiveRecord-style model behavior to subclasses.
  #
  # @abstract
  class AbstractModel
    include Attributable
    include Dirty
    include Relatable
    
    # Returns a boolean denoting if the record is new or existing. This
    # method is provided for subclasses to use to differentiate between
    # creating a new object or saving an existing one. An example of this
    # is {HardDrive#save} which will create a new hard drive if it didn't
    # previously exist, or save an old one if it did exist.
    def new_record?
      @new_record = true if @new_record.nil?
      @new_record
    end
    
    # Saves the model attributes and relationships.
    #
    # The method can be passed any arbitrary arguments, which are 
    # implementation specific (see {VM#save}, which does this).
    def save(*args)
      # Go through changed attributes and call save_attribute for
      # those only
      changes.each do |key, values|
        save_attribute(key, values[1], *args)
      end

      save_relationships(*args)
      
      # No longer a new record
      @new_record = false
    end
    
    # Saves a single attribute of the model. This method on the abstract
    # model does nothing on its own, and is expected to be overridden
    # by any subclasses. 
    #
    # This method clears the dirty status of the attribute.
    def save_attribute(key, value, *args)
      clear_dirty!(key)
    end
    
    # Sets the initial attributes from a hash. This method is meant to be used
    # once to initially setup the attributes. It is **not a mass-assignment**
    # method for updating attributes.
    #
    # This method does **not** affect dirtiness, but also does not clear it. 
    # This means that if you call populate_attributes, the same attributes 
    # that were dirty before the call will be dirty after the call (but no 
    # more and no less). This distinction is important because most subclasses 
    # of AbstractModel only save changed attributes, and ignore unchanged 
    # attributes. Attempting to change attributes through this method will 
    # cause them to not be saved, which is surely unexpected behaviour for 
    # most users.
    #
    # Calling this method will also cause the model to assume that it is not
    # a new record (see {#new_record?}).
    def populate_attributes(attribs)
      # No longer a new record
      @new_record = false
      
      ignore_dirty do
        super
        
        populate_relationships(attribs)
      end
    end 
    
    # Overwrites {Attributable#write_attribute} to set the dirty state of
    # the written attribute. See {Dirty#set_dirty!} as well.
    def write_attribute(name, value)
      set_dirty!(name, read_attribute(name), value)
      super
    end
    
    # Destroys the model. The exact behaviour of this method is expected to be
    # defined on the subclasses. This method on AbstractModel simply
    # propagates the destroy to the dependent relationships. For more information
    # on relationships, see {Relatable}.
    def destroy(*args)
      # Destroy dependent relationships
      self.class.relationships.each do |name, options|
        destroy_relationship(name, *args) if options[:dependent] == :destroy
      end
    end
  end
end