module VirtualBox
  # A VirtualBox model is an abtraction over the various data
  # items represented by a virtual machine. It allows the gem to
  # define fields on data items which are validated and later can 
  # be persisted. 
  class AbstractModel
    class <<self
      # Defines an attribute on the model. Specify a name, which will
      # be used automatically for reading/writing.
      def attribute(name, options = {})
        @attributes ||= {}
        @attributes[name.to_sym] = options
      end
    
      # Returns the hash of attributes and their associated options
      def attributes
        @attributes
      end
    end
    
    def initialize
      @changed_attributes = {}
      @attribute_values = {}
    end

    # Does the initial population of the various attributes. This sets
    # the initial values which the model uses to check which have changed.
    def populate_attributes(attribs)
      ignore_dirty do
        self.class.attributes.each do |key, options|
          write_attribute(key, attribs[key])
        end
      end
    end
    
    def write_attribute(name, value)
      set_dirty!(name, value)
      @attribute_values[name] = value
    end
    
    def read_attribute(name)
      @attribute_values[name]
    end
    
    def has_attribute?(name)
      self.class.attributes.has_key?(name.to_sym)
    end
    
    def readonly_attribute?(name)
      name = name.to_sym
      has_attribute?(name) && self.class.attributes[name][:readonly]
    end
    
    def set_dirty!(name, value)
      current = @attribute_values[name]
      
      if current != value
        # If its the first time this attribute has changed, store the
        # original value in the first field
        @changed_attributes[name] ||= [current, nil]
      
        # Then store the changed value
        @changed_attributes[name][1] = value
        
        # If the value changed back to the original value, remove from the
        # dirty hash
        if @changed_attributes[name][0] == @changed_attributes[name][1]
          @changed_attributes.delete(name)
        end
      end
    end
    
    # Runs the block, passing in the object itself. Guarantees the dirty
    # state will be the same before and after the method call, but not
    # within the block itself.
    def ignore_dirty(&block)
      current_changes = @changed_attributes.dup rescue nil
      yield self
      @changed_attributes = current_changes
    end
    
    def changed?(attribute = nil)
      if attribute.nil?
        !@changed_attributes.empty?
      else
        @changed_attributes.has_key?(attribute)
      end
    end
    
    def changes
      @changed_attributes
    end
    
    def method_missing(meth, *args)
      meth_string = meth.to_s
      
      if has_attribute?(meth)
        read_attribute(meth)
      elsif meth_string =~ /^(.+?)=$/ && has_attribute?($1) && !readonly_attribute?($1)
        write_attribute($1.to_sym, *args)
      elsif meth_string =~ /^(.+?)_changed\?$/ && has_attribute?($1)
        changed?($1.to_sym)
      elsif meth_string =~ /^(.+?)_change$/ && has_attribute?($1)
        changes[$1.to_sym]
      elsif meth_string =~ /^(.+?)_was$/ && has_attribute?($1)
        change = changes[$1.to_sym]
        if change.nil?
          read_attribute($1.to_sym)
        else
          change[0]
        end
      else
        super
      end
    end
  end
end