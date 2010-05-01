module VirtualBox
  class AbstractModel
    # Provides validation methods for a class. Unlike ActiveRecord,
    # validations are instance-level rather than class-level.
    module Validatable
      def errors
        @errors ||= {}
      end

      def errors_on(field)
        @errors[field.to_sym]
      end

      def full_error_messages
        full_error_messages = Array.new
        errors.each do |field_name, messages|
          messages.each do |message|
            human_field_name = field_name.to_s.gsub('_', ' ').capitalize
            full_error_messages << "#{human_field_name} #{message}"
          end
        end
        full_error_messages
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

      # Validates the presence (non-emptiness) of a field or fields. This
      # validation fails if the specified fields are either blank ("") or
      # nil.
      #
      # Additionally, a custom error message can be specified:
      #
      #     validates_presence_of :foo, :bar
      #     validates_presence_of :baz, :message => "must not be blank!"
      #
      # @return [Boolean]
      def validates_presence_of(*fields)
        options = {
          :message => "can't be blank."
        }

        options.merge!(fields.last.is_a?(Hash) ? fields.pop : {})

        fields.collect { |field|
          value = send(field)
          if value.nil? || value.to_s.empty?
            add_error(field, options[:message])
            false
          else
            true
          end
        }.compact.all? { |v| v == true }
      end

      def validates_format_of(*fields)
        options = fields.last.is_a?(Hash) ? fields.pop : Hash.new

        fields.collect { |field|
          value = send(field)
          # Use validates_presence_of if you need it to be set
          next if value.nil? || value.to_s.empty?
          if options[:with] && value =~ options[:with]
            true
          else
            message = options[:message] || "is not properly formatted."
            add_error(field, message)
            false
          end
        }.compact.all? { |v| v == true }
      end

      # Don't need to use this if you also use validates_inclusion_of
      def validates_numericality_of(*fields)
        options = fields.last.is_a?(Hash) ? fields.pop : Hash.new

        fields.collect { |field|
          value = send(field)
          # Use validates_presence_of if you need it to be set
          next if value.nil? || value.to_s.empty?
          if value.is_a?(Numeric) && value.to_s =~ /^\d$/
            true
          else
            message = options[:message] || "is not a number."
            add_error(field, message)
            false
          end
        }.compact.all? { |v| v == true }
      end

      def validates_inclusion_of(*fields)
        options = fields.last.is_a?(Hash) ? fields.pop : Hash.new

        fields.collect { |field|
          value = send(field)
          # Use validates_presence_of if you need it to be set
          return if value.nil? || value.to_s.empty?
          if options[:in] && options[:in].include?(value)
            true
          else
            message = (options[:message] || "value %s is not included in the list.") % value
            add_error(field, message)
            false
          end
        }.compact.all? { |v| v == true }
      end
    end
  end
end