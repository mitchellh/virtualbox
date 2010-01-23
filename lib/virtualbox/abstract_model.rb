require 'virtualbox/abstract_model/dirty'

module VirtualBox
  # A VirtualBox model is an abtraction over the various data
  # items represented by a virtual machine. It allows the gem to
  # define fields on data items which are validated and later can 
  # be persisted. 
  class AbstractModel
    include Dirty
    
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
          value_key = options[:populate_key] || key
          write_attribute(key, attribs[value_key])
        end
      end
    end
    
    def write_attribute(name, value)
      set_dirty!(name, @attribute_values[name], value)
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
    
    def method_missing(meth, *args)
      meth_string = meth.to_s
      
      if has_attribute?(meth)
        read_attribute(meth)
      elsif meth_string =~ /^(.+?)=$/ && has_attribute?($1) && !readonly_attribute?($1)
        write_attribute($1.to_sym, *args)
      else
        super
      end
    end
  end
end