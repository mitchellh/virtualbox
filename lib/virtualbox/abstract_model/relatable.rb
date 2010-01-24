module VirtualBox
  class AbstractModel
    # Provides simple relationship features to any class. These relationships
    # can be anything, since this module makes no assumptions and doesn't
    # differentiate between "has many" or "belongs to" or any of that. 
    #
    # The way it works is simple:
    #   1. Relationships are defined with a relationship name and a
    #      class of the relationship objects.
    #   2. Nothing happens initially, since relationships are lazy-loaded.
    #   3. Once a relationship method is called (by its name), this module
    #      calls "load_relationship(caller, data)" on the relationship class,
    #      which is expected to return an array or a single object or
    #      whatever the relationship is.
    module Relatable
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        # Define a relationship
        def relationship(name, klass, options = {})
          @relationships ||= {}
          @relationships[name] = { :klass => klass }.merge(options)
        end
        
        # Returns a hash of all the relationships
        def relationships
          @relationships ||= {}
        end
      end
      
      # Saves the model, calls save_relation on all relations. It is up to
      # the relation to determine whether anything changed, etc.
      def save_relationships(*args)
        self.class.relationships.each do |name, options|
          options[:klass].save_relationship(self, relationship_data[name], *args)
        end
      end
      
      # The equivalent to Attributable's populate_fields, but works a bit
      # differently (read above).
      def populate_relationships(data)
        self.class.relationships.each do |name, options|
          relationship_data[name] = options[:klass].populate_relationship(self, data)
        end
      end
      
      def relationship_data
        @relationship_data ||= {}
      end
      
      def has_relationship?(key)
        self.class.relationships.has_key?(key.to_sym)
      end
      
      def method_missing(meth, *args)
        meth_string = meth.to_s

        if has_relationship?(meth)
          relationship_data[meth.to_sym]
        else
          super
        end
      end
    end
  end
end