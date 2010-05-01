module VirtualBox
  class AbstractModel
    # Provides validation methods for a class. Unlike ActiveRecord,
    # validations are instance-level rather than class-level.
    module Validatable
      # Returns the errors on a model. The structure of this is a hash, keyed
      # by the field name. The value of each member in the hash is an array of
      # error messages.
      #
      # @return [Hash]
      def errors
        @errors ||= {}
      end

      # Returns the errors on a specific field. This returns nil if there are
      # no errors, otherwise it returns an array of error messages.
      def errors_on(field)
        @errors[field.to_sym]
      end

      # Adds an error to a field. The error is a message.
      def add_error(field, error)
        errors[field] ||= []
        errors[field].push(error)
      end

      # Clears all the errors from a model.
      def clear_errors
        @errors = {}
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

      # This method calls the validate method on the model (which any subclass
      # is expected to implement), and then checks that the validations didn't
      # add any errors.
      #
      # @return [Boolean]
      def valid?
        validate
        errors.empty?
      end

      # Subclasses should override this method. Validation can be done any
      # way an implementer feels. Helper methods such as {#validates_presence_of},
      # {#validates_inclusion_of}, etc. exist, but they're use isn't required.
      # {#add_error} can be used to add an error to any field. By convention
      # this method should return `true` or `false` to signal any errors.
      #
      # @return [Boolean]
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
        options = __validates_extract_options(fields, {
          :message => "can't be blank."
        })

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

      # Validates the format of a field with a given regular expression.
      #
      #     validates_format_of :foo, :with => /\d+/
      #
      def validates_format_of(*fields)
        options = __validates_extract_options(fields, {
          :with => nil,
          :message => "is not properly formatted."
        })

        fields.collect { |field|
          value = send(field)
          # Use validates_presence_of if you need it to be set
          next if value.nil? || value.to_s.empty?
          if options[:with] && value =~ options[:with]
            true
          else
            add_error(field, options[:message])
            false
          end
        }.compact.all? { |v| v == true }
      end

      # Validates the numericality of a specific field.
      #
      #     validates_numericality_of :field
      #
      def validates_numericality_of(*fields)
        options = __validates_extract_options(fields, {
          :message => "is not a number."
        })

        fields.collect { |field|
          value = send(field)
          # Use validates_presence_of if you need it to be set
          next if value.nil? || value.to_s.empty?
          if value.is_a?(Numeric) && value.to_s =~ /^\d$/
            true
          else
            add_error(field, options[:message])
            false
          end
        }.compact.all? { |v| v == true }
      end

      # Validates that a field's value is within a specific range,
      # array, etc.
      #
      #     validates_inclusion_of :foo, :in => [1,2,3]
      #     validates_inclusion_of :bar, :in => (1..6)
      #
      def validates_inclusion_of(*fields)
        options = __validates_extract_options(fields, {
          :in => nil,
          :message => "value %s is not included in the list."
        })

        fields.collect { |field|
          value = send(field)
          # Use validates_presence_of if you need it to be set
          return if value.nil? || value.to_s.empty?
          if options[:in] && options[:in].include?(value)
            true
          else
            message = options[:message] % value
            add_error(field, message)
            false
          end
        }.compact.all? { |v| v == true }
      end

      # Internal method. Should never be called.
      def __validates_extract_options(fields, defaults)
        defaults.merge(fields.last.is_a?(Hash) ? fields.pop : {})
      end
    end
  end
end