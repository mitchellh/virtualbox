module VirtualBox
  class AbstractModel
    # Module which can be included into any other class which allows
    # that class to have attributes using the "attribute" class method.
    # This creates the reader/writer for the attribute but also provides
    # other useful options such as readonly attributes, default values,
    # and more.
    #
    # Make sure to also see the {ClassMethods}.
    #
    # ## Defining a Basic Attribute
    #
    #     attribute :name
    #
    # The example above would put the "name" attribute on the class. This
    # would give the class the following abilities
    #
    #     instance.name = "Harry!"
    #     puts instance.name # => "Harry!"
    #
    # Basic attributes alone are not different than ruby's built-in
    # `attr_*` methods.
    #
    # ## Defining a Readonly Attribute
    #
    #     attribute :age, :readonly => true
    #
    # The example above allows age to be read, but not written to via the
    # `age=` method. The attribute is still able to written using
    # {#write_attribute} but this is generally only for
    # inter-class use, and not for users of it.
    #
    # ## Defining Default Values
    #
    #     attribute :format, :default => "VDI"
    #
    # The example above applies a default value to format. So if no value
    # is ever given to it, `format` would return `VDI`.
    #
    # ## Populating Multiple Attributes
    #
    # Attributes can be mass populated using {#populate_attributes}. Below
    # is an example of the use.
    #
    #     class Person
    #       include Attributable
    #
    #       attribute :name
    #       attribute :age, :readonly => true
    #
    #       def initialize
    #         populate_attributes({
    #           :name => "Steven",
    #           :age => 27
    #         })
    #       end
    #     end
    #
    # **Note:** Populating attributes is not the same as mass-updating attributes.
    # {#populate_attributes} is meant to do initial population only. There is
    # currently no method for mass assignment for updating.
    #
    # ## Custom Populate Keys
    #
    # Sometimes the attribute names don't match the keys of the hash that will be
    # used to populate it. For this purpose, you can define a custom
    # `populate_key`. Example:
    #
    #     attribute :path, :populate_key => :location
    #
    #     def initialize
    #       populate_attributes(:location => "Home")
    #       puts path # => "Home"
    #     end
    #
    # ## Lazy Loading Attributes
    #
    # While most attributes are fairly trivial to calculate and populate, sometimes
    # attributes may have an expensive cost to populate, and are generally not worth
    # populating unless a user of the class requests that attribute. This is known as
    # _lazy loading_ the attributes. This is possibly by specifying the `:lazy` option
    # on the attribute. In this case, the first time (and _only_ the first time) the
    # attribute is requested, `load_attribute` will be called with the name of the
    # attribute as the parameter. This method is then expected to call `write_attribute`
    # on that attribute to give it a value.
    #
    #     class ExpensiveAttributeModel
    #       include VirtualBox::AbstractModel::Attributable
    #       attribute :expensive_attribute, :lazy => true
    #
    #       def load_attribute(name)
    #         if name == :expensive_attribute
    #           write_attribute(name, perform_expensive_calculation)
    #         end
    #       end
    #     end
    #
    # Using the above definition, we could use the class like so:
    #
    #     # Initializing is fast, since no attribute population is done
    #     model = ExpensiveAttributeModel.new
    #
    #     # But this is slow, since it has to calculate.
    #     puts model.expensive_attribute
    #
    #     # But ONLY THE FIRST TIME. This time is FAST!
    #     puts model.expensive_attribute
    #
    # In addition to calling `load_attribute` on initial read, `write_attribute`
    # when performed on a lazy loaded attribute will mark it as "loaded" so there
    # will be no load called on the first request. Example, using the above class
    # once again:
    #
    #     model = ExpensiveAttributeModel.new
    #     model.write_attribute(:expensive_attribute, 42)
    #
    #     # This is FAST, since "load_attribute" is not called
    #     puts model.expensive_attribute # => 42
    #
    module Attributable
      def self.included(base)
        base.extend ClassMethods
      end

      # Defines the class methods for the {Attributable} module. For
      # detailed overview documentation, see {Attributable}.
      module ClassMethods
        # Defines an attribute on the model.
        #
        # @param [Symbol] name The name of the attribute, which will also be
        #   used to set the accessor methods.
        # @option options [Boolean] :readonly (false) If true, attribute will be readonly.
        #   More specifically, the `attribute=` method won't be defined for it.
        # @option options [Object] :default (nil) Specifies a default value for the
        #   attribute.
        # @option options [Symbol] :populate_key (attribute name) Specifies
        #   a custom populate key to use for {Attributable#populate_attributes}
        def attribute(name, options = {})
          name = name.to_sym
          attributes[name] = options

          # Create the method for reading this attribute
          define_method(name) { read_attribute(name) }

          # Create the writer method for it unless the attribute is readonly,
          # then remove the method if it exists
          if !options[:readonly]
            define_method("#{name}=") do |value|
              write_attribute(name, value)
            end
          elsif method_defined?("#{name}=")
            undef_method("#{name}=")
          end
        end

        # Returns the hash of attributes and their associated options.
        def attributes
          @attributes ||= {}
        end

        # Used to propagate attributes to subclasses. This method makes sure that
        # subclasses of a class with {Attributable} included will inherit the
        # attributes as well, which would be the expected behaviour.
        def inherited(subclass)
          super rescue NoMethodError

          attributes.each do |name, option|
            subclass.attribute(name, option)
          end
        end
      end

      # Does the initial population of the various attributes. It will
      # ignore attributes which are not defined or have no value in the
      # hash.
      #
      # Population uses the attributes `populate_key` if present to
      # determine which value to take. Example:
      #
      #     attribute :name, :populate_key => :namae
      #     attribute :age
      #
      #     def initialize
      #       populate_attributes(:namae => "Henry", :age => 27)
      #     end
      #
      # The above example would set `name` to `Henry` since that is
      # the `populate_key`. If a `populate_key` is not present, the
      # attribute name is used.
      def populate_attributes(attribs)
        self.class.attributes.each do |key, options|
          value_key = options[:populate_key] || key
          write_attribute(key, attribs[value_key])
        end
      end

      # Writes an attribute. This method ignores the `readonly` option
      # on attribute definitions. This method is mostly meant for
      # internal use on setting attributes (including readonly
      # attributes), whereas users of a class which includes this
      # module should use the accessor methods, such as `name=`.
      def write_attribute(name, value)
        attributes[name] = value
      end

      # Reads an attribute. This method will return `nil` if the
      # attribute doesn't exist. If the attribute does exist but
      # doesn't have a value set, it'll use the `default` value
      # if specified.
      def read_attribute(name)
        if has_attribute?(name)
          if lazy_attribute?(name) && !loaded_attribute?(name)
            # Load the lazy attribute
            load_attribute(name.to_sym)
          end

          attributes[name] || self.class.attributes[name][:default]
        end
      end

      # Returns a hash of all attributes and their options.
      def attributes
        @attribute_values ||= {}
      end

      # Returns boolean value denoting if an attribute exists.
      def has_attribute?(name)
        self.class.attributes.has_key?(name.to_sym)
      end

      # Returns boolean value denoting if an attribute is "lazy loaded"
      def lazy_attribute?(name)
        has_attribute?(name) && self.class.attributes[name.to_sym][:lazy]
      end

      # Returns boolean value denoting if an attribute has been loaded
      # yet.
      def loaded_attribute?(name)
        attributes.has_key?(name)
      end

      # Returns a boolean value denoting if an attribute is readonly.
      # This method also returns false for **nonexistent attributes**
      # so it should be used in conjunction with {#has_attribute?} if
      # existence is important.
      def readonly_attribute?(name)
        name = name.to_sym
        has_attribute?(name) && self.class.attributes[name][:readonly]
      end
    end
  end
end