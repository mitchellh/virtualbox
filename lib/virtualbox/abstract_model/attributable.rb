module VirtualBox
  class AbstractModel
    # Module which can be included into any other class which allows
    # that class to have attributes using the "attribute" class method.
    # This creates the reader/writer for the attribute but also allows
    # the attribute to be marked as "readonly" for example.
    module Attributable
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        # Defines an attribute on the model. Specify a name, which will
        # be used automatically for reading/writing.
        def attribute(name, options = {})
          attributes[name.to_sym] = options
        end

        # Returns the hash of attributes and their associated options
        def attributes
          @attributes ||= {}
          @attributes.merge(super) rescue @attributes
        end
        
        # Make sure subclasses inherit attributes
        def inherited(subclass)
          super rescue NoMethodError
          
          attributes.each do |name, option|
            subclass.attribute(name, option)
          end
        end
      end

      def initialize
        @changed_attributes = {}
        @attribute_values = {}
      end

      # Does the initial population of the various attributes. This sets
      # the initial values which the model uses to check which have changed.
      def populate_attributes(attribs)
        self.class.attributes.each do |key, options|
          value_key = options[:populate_key] || key
          write_attribute(key, attribs[value_key])
        end
      end

      def write_attribute(name, value)
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
end