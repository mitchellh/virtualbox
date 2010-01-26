module VirtualBox
  class AbstractModel
    # Tracks "dirtiness" of values for a class. Its not tied to AbstractModel
    # in any way other than the namespace. 
    #
    # # Checking if a Value was Changed
    #
    # Dynamic methods allow functionality for checking if values changed:
    #
    #     obj.foo_changed?
    #
    # # Previous Value
    #
    # Can also view the previous value of an attribute:
    # 
    #     obj.foo # => "foo" initially
    #     obj.foo = "bar"
    #     obj.foo_was # => "foo"
    #
    # # Previous and Current Value
    #
    # Using the `_change` dynamic method, can view the changes of a field.
    #
    #     obj.foo # => "foo" initially
    #     obj.foo = "bar"
    #     obj.foo_change # => ["foo", "bar"]
    #
    # # All Changes
    #
    # Can also view all changes for a class with the `changes` method.
    #
    #     obj.foo # => "foo" initially
    #     obj.bar # => "bar" initially
    #     obj.foo = "far"
    #     obj.bar = "baz"
    #     obj.changes # => { :foo => ["foo", "far"], :bar => ["bar", "baz"]}
    #
    # # Setting Dirty
    #
    # Dirtiness tracking only occurs for values which the implementor
    # explicitly sets as dirty. This is done with the {#set_dirty!}
    # method. Example implementation below:
    #
    #     class Person
    #       include VirtualBox::AbstractModel::Dirty
    #
    #       attr_reader :name
    #
    #       def name=(value)
    #         set_dirty!(:name, @name, value)
    #         @name = value
    #       end
    #     end
    #
    # The above example has all the changes necessary to track changes
    # on an attribute.
    #
    # # Ignoring Dirtiness Tracking
    # 
    # Sometimes, for features such as mass assignment, dirtiness tracking
    # should be disabled. This can be done with the `ignore_dirty` method.
    #
    #     ignore_dirty do |obj|
    #       obj.name = "Foo"
    #     end
    #     
    #     obj.changed? # => false
    #
    # # Clearing Dirty State
    #
    # Sometimes, such as after saving a model, dirty states should be cleared.
    # This can be done with the `clear_dirty!` method.
    #
    #     obj.clear_dirty!(:name)
    #     obj.name_changed? # => false
    #
    module Dirty
      # Manages dirty state for an attribute. This method will handle
      # setting the dirty state of an attribute (or even clearing it
      # if the old value is reset). Any implementors of this mixin should
      # call this for any fields they want tracked.
      #
      # @param [Symbol] name Name of field
      # @param [Object] current Current value (not necessarilly the
      #   original value, but the **current** value)
      # @param [Object] value The new value being set
      def set_dirty!(name, current, value)
        if current != value
          # If its the first time this attribute has changed, store the
          # original value in the first field
          changes[name] ||= [current, nil]

          # Then store the changed value
          changes[name][1] = value

          # If the value changed back to the original value, remove from the
          # dirty hash
          if changes[name][0] == changes[name][1]
            changes.delete(name)
          end
        end
      end
      
      # Clears dirty state for a field.
      #
      # @param [Symbol] key The field to clear dirty state.
      def clear_dirty!(key=nil)
        if key.nil?
          @changed_attributes = {}
        else
          changes.delete(key)
        end
      end

      # Ignores any dirty changes during the duration of the block. 
      # Guarantees the dirty state will be the same before and after 
      # the method call, but not within the block itself.
      def ignore_dirty(&block)
        current_changes = @changed_attributes.dup rescue nil
        yield self
        @changed_attributes = current_changes
      end

      # Returns boolean denoting if field changed or not. If no attribute
      # is specified, returns true of false showing whether the model
      # changed at all.
      #
      # @param [Symbol] attribute The attribute to check, or if nil,
      #   all fields checked.
      def changed?(attribute = nil)
        if attribute.nil?
          !changes.empty?
        else
          changes.has_key?(attribute)
        end
      end

      # Returns hash of changes. Keys are fields, values are an
      # array of the original value and the current value.
      #
      # @return [Hash]
      def changes
        @changed_attributes ||= {}
      end
      
      # Method missing is used to implement the "magic" methods of
      # `field_changed`, `field_change`, and `field_was`.
      def method_missing(meth, *args)
        meth_string = meth.to_s
        
        if meth_string =~ /^(.+?)_changed\?$/ 
          changed?($1.to_sym)
        elsif meth_string =~ /^(.+?)_change$/
          changes[$1.to_sym]
        elsif meth_string =~ /^(.+?)_was$/
          change = changes[$1.to_sym]
          if change.nil?
            nil
          else
            change[0]
          end
        else
          super
        end
      end
    end
  end
end