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
    attribute :parent, :readonly => true, :property => false
    attribute :interface, :readonly => true, :property => false
    attribute :name, :readonly => true
    attribute :port_count
    attribute :bus, :readonly => true
    attribute :controller_type

    class <<self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<StorageController>]
      def populate_relationship(caller, data)
        if data.is_a?(COM::Interface::Machine)
          populate_array_relationship(caller, data)
        elsif data.is_a?(MediumAttachment)
          populate_attachment_relationship(caller, data)
        end
      end

      # Populates a has many relationship for a {VM}.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<StorageController>]
      def populate_array_relationship(caller, imachine)
        relation = Proxies::Collection.new(caller)

        imachine.storage_controllers.each do |icontroller|
          relation << new(caller, icontroller)
        end

        relation
      end

      # Populates a single relationship for a {MediumAttachment}.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<StorageController>]
      def populate_attachment_relationship(caller, attachment)
        # Find the storage controller with the matching name
        attachment.parent.storage_controllers.find do |sc|
          sc.name == attachment.controller_name
        end
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
      def save_relationship(caller, controllers)
        controllers.each do |sc|
          sc.save
        end
      end
    end

    # Since storage controllers still can't be created from scratch,
    # this method shouldn't be called. Instead, storage controllers
    # can be retrieved through relationships of other models such
    # as {VM}.
    def initialize(caller, icontroller)
      super()

      populate_attributes({
        :parent => caller,
        :interface => icontroller
      }, :ignore_relationships => true)
      load_interface_attributes(icontroller)
      clear_dirty!
    end

    # Retrieves the array of medium attachments related to this storage controller.
    # This is not implemented as a relationship simply because it would have been
    # difficult to do so (circular) and its not really necessary.
    def medium_attachments
      parent.medium_attachments.find_all do |ma|
        ma.storage_controller == self
      end
    end

    # Saves the storage controller. This method shouldn't be called directly.
    # Instead, {VM#save} should be called, which will save all attached storage
    # controllers as well. This will setup the proper parameter for `interface`
    # here.
    def save
      parent.with_open_session do |session|
        machine = session.machine
        save_changed_interface_attributes(machine.get_storage_controller_by_name(name))
      end
    end

    # Destroys the storage controller. This first detaches all attachments on this
    # storage controller. Note that this does *not* delete the media on the attachments,
    # unless specified by the options.
    def destroy(*args)
      # First remove all attachments
      medium_attachments.each do |ma|
        ma.destroy(*args)
      end

      # Finally, remove ourselves
      parent.with_open_session do |session|
        machine = session.machine
        machine.remove_storage_controller(name)
      end
    end
  end
end