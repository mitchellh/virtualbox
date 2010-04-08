module VirtualBox
  # Represents the attachment of a medium (DVD, Hard Drive, etc) to a
  # virtual machine, and specifically to a {StorageController}.
  class MediumAttachment < AbstractModel
    attribute :parent, :readonly => true, :property => false
    attribute :controller_name, :readonly => :true, :property => :controller
    attribute :port, :readonly => true
    attribute :device, :readonly => true
    attribute :passthrough, :readonly => true
    attribute :type, :readonly => true
    relationship :medium, :Medium
    relationship :storage_controller, :StorageController

    class <<self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<MediumAttachment>]
      def populate_relationship(caller, imachine)
        relation = Proxies::Collection.new(caller)

        imachine.medium_attachments.each do |ima|
          relation << new(caller, ima)
        end

        relation
      end
    end

    def initialize(parent, imedium_attachment)
      populate_attributes({:parent => parent}, :ignore_relationships => true)
      initialize_attributes(imedium_attachment)
    end

    def initialize_attributes(ima)
      load_interface_attributes(ima)
      populate_relationship(:medium, ima.medium)
      populate_relationship(:storage_controller, self)
    end

    # Detaches the medium from it's parent virtual machine. Note that this
    # **does not delete** the `medium` which this attachment references; it
    # merely removes the assocation of said medium with this attachment's
    # virtual machine.
    def detach
      parent.with_open_session do |session|
        machine = session.machine

        machine.detach_device(storage_controller.name, port, device)
        machine.save_settings
      end
    end

    # Destroy this medium attachment. This simply detaches the medium attachment.
    # This will also delete the medium if that option is specified.
    def destroy(opts={})
      detach
      medium.destroy(opts[:destroy_medium] == :delete) if opts[:destroy_medium] && medium
    end
  end
end