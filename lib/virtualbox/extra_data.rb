module VirtualBox
  # Represents "extra data" which can be set on a specific
  # virtual machine or on VirtualBox as a whole. Extra data is persistent
  # key-value storage which is available as a way to store any information
  # wanted. VirtualBox uses it for storing statistics and settings. You can
  # use it for anything!
  #
  # # Extra Data on a Virtual Machine
  #
  # Setting extra data on a virtual machine is easy. All {VM} objects have a
  # `extra_data` relationship which is just a simple ruby hash, so you can treat
  # it like one! Once the data is set, simply saving the VM will save the
  # extra data. An example below:
  #
  #     vm = VirtualBox::VM.find("FooVM")
  #     vm.extra_data["ruby-accessed"]  = "yes, yes it was"
  #     vm.save
  #
  # Now, let's say you open up the VM again some other time:
  #
  #     vm = VirtualBox::VM.find("FooVM")
  #     puts vm.extra_data["ruby-accessed"]
  #
  # It acts just like a hash!
  #
  # # Global Extra Data
  #
  # Extra data doesn't need to be tied to a specific virtual machine. It can also
  # exist globally. Setting global extra-data is just as easy:
  #
  #     VirtualBox::ExtraData.global["some-key"] = "some value"
  #     VirtualBox::ExtraData.global.save
  #
  class ExtraData < Hash
    include AbstractModel::Dirty

    attr_accessor :parent
    attr_reader :interface

    @@global_data = nil

    class << self
      # Gets the global extra data. This will "cache" the data for
      # future use unless you set the `reload` paramter to true.
      #
      # @param [Boolean] reload If true, will reload new global data.
      # @return [Array<ExtraData>]
      def global(reload=false)
        if !@@global_data || reload
          @@global_data = Global.global.extra_data
        end

        @@global_data
      end

      # Populates a relationship with another model.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<ExtraData>]
      def populate_relationship(caller, interface)
        data = new(caller, interface)

        interface.get_extra_data_keys.each do |key|
          data[key] = interface.get_extra_data(key)
        end

        data.clear_dirty!
        data
      end

      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, data)
        data.save
      end
    end

    # Initializes an extra data object.
    #
    # @param [Hash] data Initial attributes to populate.
    def initialize(parent, interface)
      @parent = parent
      @interface = interface
    end

    # Set an extradata key-value pair. Overrides ruby hash implementation
    # to set dirty state. Otherwise that, behaves the same way.
    def []=(key,value)
      set_dirty!(key, self[key], value)
      super
    end

    # Saves extra data. This method does the same thing for both new
    # and existing extra data, since virtualbox will overwrite old data or
    # create it if it doesn't exist.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def save
      changes.each do |key, value|
        interface.set_extra_data(key.to_s, value[1].to_s)

        clear_dirty!(key)

        if value[1].nil?
          # Remove the key from the hash altogether
          hash_delete(key.to_s)
        end
      end
    end

    # Alias away the old delete method so its still accessible somehow
    alias :hash_delete :delete

    # Deletes the specified extra data.
    #
    # @param [String] key The extra data key to delete
    def delete(key)
      interface.set_extra_data(key.to_s, nil)
      hash_delete(key.to_s)
    end
  end
end
