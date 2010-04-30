module VirtualBox
  # Represents a description of a virtual system in an {Appliance}. This contains
  # the values that are in the OVF files as well as recommend values from VirtualBox.
  class VirtualSystemDescription < AbstractModel
    attribute :interface, :readonly => true
    attribute :descriptions, :readonly => true, :default => {}

    class <<self
      def populate_relationship(caller, data)
        result = Proxies::Collection.new(caller)

        data.each do |vsd|
          result << new(vsd)
        end

        result
      end
    end

    def initialize(ivsd)
      write_attribute(:interface, ivsd)
      initialize_attributes(ivsd)
    end

    def initialize_attributes(ivsd)
      # Grab all the descriptions, iterate over each, and add to the hash of
      # descriptions. This multiple loop method is used instead of `get_description` since
      # that method doesn't work well with MSCOM.
      COM::Util.versioned_interface(:VirtualSystemDescriptionType).each_with_index do |type, index|
        COM::Util.versioned_interface(:VirtualSystemDescriptionValueType).each_with_index do |value_type, value_index|
          value = ivsd.get_values_by_type(type, value_type)
          if value && value != [] && value != [nil]
            descriptions[type] ||= {}
            descriptions[type][value_type] = value.first
          end
        end
      end

      # Clear dirtiness, since this should only be called initially and
      # therefore shouldn't affect dirtiness
      clear_dirty!

      # But this is an existing record
      existing_record!
    end
  end
end