module VirtualBox
  class AbstractModel
    # Provides simple relationship features to any class. These relationships
    # can be anything, since this module makes no assumptions and doesn't
    # differentiate between "has many" or "belongs to" or any of that. 
    #
    # The way it works is simple:
    # 
    # 1. Relationships are defined with a relationship name and a
    #    class of the relationship objects.
    # 2. When {#populate_relationships} is called, `populate_relationship` is
    #    called on each relationship class (example: {StorageController.populate_relationship}).
    #    This is expected to return the relationship, which can be any object.
    # 3. When {#save_relationships} is called, `save_relationship` is
    #     called on each relationship class, which manages saving its own
    #     relationship.
    # 4. When {#destroy_relationships} is called, `destroy_relationship` is
    #     called on each relationship class, which manages destroying
    #     its own relationship.
    #
    # Be sure to read {ClassMethods} for complete documentation of methods.
    #
    # # Defining Relationships
    #
    # Every relationship has two mandatory parameters: the name and the class.
    #
    #     relationship :bacons, Bacon
    #
    # In this case, there is a relationship `bacons` which refers to the `Bacon`
    # class.
    #
    # # Accessing Relationships
    #
    # Relatable offers up dynamically generated accessors for every relationship
    # which simply returns the relationship data.
    #
    #     relationship :bacons, Bacon
    #
    #     # Accessing through an instance "instance"
    #     instance.bacons # => whatever Bacon.populate_relationship created
    #
    # # Dependent Relationships
    #
    # By setting `:dependent => :destroy` on relationships, {AbstractModel}
    # will automatically call {#destroy_relationships} when {AbstractModel#destroy}
    # is called.
    #
    # This is not a feature built-in to Relatable but figured it should be
    # mentioned here.
    module Relatable
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        # Define a relationship. The name and class must be specified. This
        # class will be used to call the `populate_relationship, 
        # `save_relationship`, etc. methods.
        #
        # @param [Symbol] name Relationship name. This will also be used for
        #   the dynamically generated accessor.
        # @param [Class] klass Class of the relationship.
        # @option options [Symbol] :dependent (nil) - If set to `:destroy`
        #   {AbstractModel#destroy} will propagate through to relationships.
        def relationship(name, klass, options = {})
          @relationships ||= {}
          @relationships[name] = { :klass => klass }.merge(options)
        end
        
        # Returns a hash of all the relationships.
        #
        # @return [Hash]
        def relationships
          @relationships ||= {}
        end
        
        # Used to propagate relationships to subclasses. This method makes sure that
        # subclasses of a class with {Relatable} included will inherit the
        # relationships as well, which would be the expected behaviour.
        def inherited(subclass)
          super rescue NoMethodError
          
          relationships.each do |name, options|
            subclass.relationship(name, nil, options)
          end
        end
      end
      
      # Saves the model, calls save_relationship on all relations. It is up to
      # the relation to determine whether anything changed, etc. Simply
      # calls `save_relationship` on each relationshp class passing in the
      # following parameters:
      #
      # * **caller** - The class which is calling save
      # * **data** - The data associated with the relationship
      #
      # In addition to those two args, any arbitrary args may be tacked on to the
      # end and they'll be pushed through to the `save_relationship` method.
      def save_relationships(*args)
        self.class.relationships.each do |name, options|
          next unless options[:klass].respond_to?(:save_relationship)
          options[:klass].save_relationship(self, relationship_data[name], *args)
        end
      end
      
      # The equivalent to {Attributable#populate_attributes}, but with
      # relationships.
      def populate_relationships(data)
        self.class.relationships.each do |name, options|
          next unless options[:klass].respond_to?(:populate_relationship)
          relationship_data[name] = options[:klass].populate_relationship(self, data)
        end
      end
      
      # Calls `destroy_relationship` on each of the relationships. Any
      # arbitrary args may be added and they will be forarded to the
      # relationship's `destroy_relationship` method.
      def destroy_relationships(*args)
        self.class.relationships.each do |name, options|
          destroy_relationship(name, *args)
        end
      end
      
      # Destroys only a single relationship. Any arbitrary args
      # may be added to the end and they will be pushed through to
      # the class's `destroy_relationship` method.
      #
      # @param [Symbol] name The name of the relationship
      def destroy_relationship(name, *args)
        options = self.class.relationships[name]
        return unless options && options[:klass].respond_to?(:destroy_relationship)
        options[:klass].destroy_relationship(self, relationship_data[name], *args)
      end
      
      # Hash to data associated with relationships. You should instead
      # use the accessors created by Relatable.
      #
      # @return [Hash]
      def relationship_data
        @relationship_data ||= {}
      end
      
      # Returns boolean denoting if a relationship exists.
      #
      # @return [Boolean]
      def has_relationship?(key)
        self.class.relationships.has_key?(key.to_sym)
      end
      
      # Sets a relationship to the given value. This is not guaranteed to
      # do anything, since "set_relationship" will be called on the class
      # that the relationship is associated with and its expected to return
      # the resulting relationship to set. 
      #
      # If the relationship class doesn't respond to the set_relationship
      # method, then an exception {NonSettableRelationshipException} will
      # be raised.
      #
      # This method is called by the "magic" method of `relationship=`.
      #
      # @param [Symbol] key Relationship key.
      # @param [Object] value The new value of the relationship.
      def set_relationship(key, value)
        key = key.to_sym
        relationship = self.class.relationships[key]
        return unless relationship
        
        raise Exceptions::NonSettableRelationshipException.new unless relationship[:klass].respond_to?(:set_relationship)
        relationship_data[key] = relationship[:klass].set_relationship(self, relationship_data[key], value)
      end
      
      # Method missing is used to add dynamic handlers for relationship
      # accessors.
      def method_missing(meth, *args)
        meth_string = meth.to_s

        if has_relationship?(meth)
          relationship_data[meth.to_sym]
        elsif meth_string =~ /^(.+?)=$/ && has_relationship?($1)
          set_relationship($1.to_sym, *args)
        else
          super
        end
      end
    end
  end
end