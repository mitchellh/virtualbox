module VirtualBox
  class AbstractModel
    # Tracks "dirtiness" of values for a class. Its not tied to AbstractModel
    # in any way other than the namespace. 
    module Dirty
      def set_dirty!(name, current, value)
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