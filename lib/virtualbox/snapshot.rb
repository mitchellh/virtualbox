module VirtualBox
  # Represents a single snapshot which can be restored or deleted.
  #
  # **It makes no sense to create snapshots from scratch, and thus this
  # model is only usable through its relationship to a {VM} object.**
  #
  #
  # ## Attributes
  #
  # This is copied directly from the class header, but lists all available
  # attributes. If you don't understand what this means, read {Attributable}.
  #
  #     attribute :parent, :readonly => true
  #     attribute :name
  #     attribute :uuid, :readonly => true
  #
  class Snapshot < AbstractModel
    attribute :parent, :readonly => true
    attribute :name
    attribute :uuid, :readonly => true

    class <<self
      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<Snapshot>]
      def populate_relationship(caller, data)
        relation = []

        counter = 0
        loop do
          index = "snapshotname" + (counter > 0 ? "-#{counter}" : '')
          break unless data[index.to_sym]
          snapshot = new(counter, caller, data)
          relation.push(snapshot)
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
        data.each do |snapshot|
          snapshot.save
        end
      end
    end

    # Since snapshots can't be created from scratch,
    # this method shouldn't be called. Instead, snapshots
    # can be retrieved through relationships of other models such
    # as {VM}.
    def initialize(index, caller, data)
      super()

      @index = index
      indexkey = (index > 0 ? "-#{index}" : '')

      # Setup the index specific attributes
      populate_data = {}
      self.class.attributes.each do |name, options|
        key = options[:populate_key] || name
        value = data["snapshot#{key}#{indexkey}".to_sym]
        populate_data[key] = value
      end

      populate_attributes(populate_data.merge({
        :parent => caller
      }))
    end

    # Saves a snapshot
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def save(raise_errors=false)
      return true unless changed?

      Command.vboxmanage("snapshot", parent.name, "edit", uuid, "--name", name)
      existing_record!
      clear_dirty!

      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end

    # Restore a snapshot
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def restore(raise_errors=false)
      Command.vboxmanage("snapshot", parent.name, "restore", uuid)
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
    
    # Delete a snapshot
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def destroy(raise_errors=false)
      Command.vboxmanage("snapshot", parent.name, "delete", uuid)
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end
  end
end