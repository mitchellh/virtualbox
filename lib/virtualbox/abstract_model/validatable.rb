module VirtualBox
  class AbstractModel
    # Provides validation methods for a class. Unlike ActiveRecord,
    # validations are instance-level rather than class-level.
    module Validatable
      def errors
        @errors ||= {}
      end
      
      def add_error(field, error)
        errors[field] ||= []
        errors[field].push(error)
      end
      
      def clear_errors
        @errors = {}
      end

      def valid?
        validate
        errors.empty?
      end
      
      # Subclasses should override this method.
      def validate
        true
      end
      
      def validates_presence_of(field)
        if field.is_a?(Array)
          field.map { |v| validates_presence_of(v) }.all? { |v| v == true }
        else
          value = send(field)
          if value.nil? || value == ""
            add_error(field, "must not be blank.")
            return false
          else
            return true
          end
        end
      end
    end
  end
end