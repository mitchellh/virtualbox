module VirtualBox
  # Represents a single storage controller which can be attached to a
  # virtual machine.
  #
  # **Currently, storage controllers can not be created from scratch.
  # Therefore, the only way to use this model is through a relationship
  # of a {VM} object.**
  #
  # # Attributes and Relationships
  #
  # Properties of the storage controller are exposed using standard ruby instance
  # methods which are generated on the fly. Because of this, they are not listed
  # below as available instance methods.
  #
  # These attributes can be accessed and modified via standard ruby-style
  # `instance.attribute` and `instance.attribute=` methods. The attributes are
  # listed below.
  #
  # Relationships are also accessed like attributes but can't be set. Instead,
  # they are typically references to other objects such as an {AttachedDevice} which
  # in turn have their own attributes which can be modified.
  #
  # ## Attributes
  #
  # This is copied directly from the class header, but lists all available
  # attributes. If you don't understand what this means, read {Attributable}.
  #
  #     attribute :parent, :readonly => true
  #     attribute :name
  #     attribute :type
  #     attribute :max_ports, :populate_key => :maxportcount
  #     attribute :ports, :populate_key => :portcount
  #
  # ## Relationships
  #
  # In addition to the basic attributes, a virtual machine is related
  # to other things. The relationships are listed below. If you don't
  # understand this, read {Relatable}.
  #
  #     relationship :devices, AttachedDevice, :dependent => :destroy
  #
  class StorageController < AbstractModel
    attribute :parent, :readonly => true
    attribute :name
    attribute :type
    attribute :ports, :populate_key => :portcount
    relationship :devices, AttachedDevice, :dependent => :destroy

    class <<self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<StorageController>]
      def populate_relationship(caller, doc)
        relation = Proxies::Collection.new(caller)

        counter = 0
        doc.css("StorageControllers StorageController").each do |sc|
          relation << new(counter, caller, sc)
          counter += 1
        end

        relation
      end

      # Destroys a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      def destroy_relationship(caller, data, *args)
        data.each { |v| v.destroy(*args) }
      end

      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, data)
        data.each do |sc|
          sc.save
        end
      end
    end

    # Since storage controllers still can't be created from scratch,
    # this method shouldn't be called. Instead, storage controllers
    # can be retrieved through relationships of other models such
    # as {VM}.
    def initialize(index, caller, data)
      super()

      @index = index

      # Setup the index specific attributes
      populate_data = {}
      data.attributes.each do |key,value|
        populate_data[key.downcase.to_sym] = value.to_s
      end

      populate_attributes(populate_data.merge({:parent => caller}), :ignore_relationships => true)
      populate_relationship(:devices, data)
    end
  end
end