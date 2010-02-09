module VirtualBox
  # Represents a single NIC (Network Interface Card) of a virtual machine.
  #
  # **Currently, new NICs can't be created, so the only way to get this
  # object is through a {VM}'s `nics` relationship.**
  #
  # # Editing a NIC
  #
  # Nics can be modified directly in their relationship to other
  # virtual machines. When {VM#save} is called, it will also save any
  # changes to its relationships.
  #
  #     vm = VirtualBox::VM.find("foo")
  #     vm.nics[0].macaddress = @new_mac_address
  #     vm.save
  #
  # # Attributes
  #
  # Properties of the model are exposed using standard ruby instance
  # methods which are generated on the fly. Because of this, they are not listed
  # below as available instance methods.
  #
  # These attributes can be accessed and modified via standard ruby-style
  # `instance.attribute` and `instance.attribute=` methods. The attributes are
  # listed below. If you aren't sure what this means or you can't understand
  # why the below is listed, please read {Attributable}.
  #
  #     attribute :parent, :readonly => :readonly
  #     attribute :nic
  #     attribute :nictype
  #     attribute :macaddress
  #     attribute :cableconnected
  #     attribute :bridgeadapter
  #
  class Nic < AbstractModel
    attribute :parent, :readonly => :readonly
    attribute :nic
    attribute :nictype, :populate_key => "type"
    attribute :macaddress, :populate_key => "MACAddress"
    attribute :cableconnected, :populate_key => "cable"
    attribute :bridgeadapter

    class <<self
      # Retrives the Nic data from human-readable vminfo. Since some data about
      # nics is not exposed in the machine-readable virtual machine info, some
      # extra parsing must be done to get these attributes. This method parses
      # the nic-specific data from this human readable information.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Hash]
      def nic_data(vmname)
        raw = VM.human_info(vmname)

        # Complicated chain of methods just maps parse_nic over each line,
        # removing invalid ones, and then converting it into a single hash.
        raw.split("\n").collect { |v| parse_nic(v) }.compact.inject({}) do |acc, obj|
          acc.merge({ obj[0] => obj[1] })
        end
      end

      # Parses nic data out of a single line of the human readable output
      # of vm info.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array] First element is nic name, second is data.
      def parse_nic(raw)
        return unless raw =~ /^NIC\s(\d):\s+(.+?)$/
        return if $2.to_s.strip == "disabled"

        data = {}
        nicname = "nic#{$1}"
        $2.to_s.split(/,\s+/).each do |raw_property|
          next unless raw_property =~ /^(.+?):\s+(.+?)$/

          data[$1.downcase.to_sym] = $2.to_s
        end

        return nicname.to_sym, data
      end

      # Populates the nic relationship for anything which is related to it.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array<Nic>]
      def populate_relationship(caller, doc)
        relation = Proxies::Collection.new(caller)

        doc.css("Hardware Network Adapter").each do |adapter|
          relation << new(caller, adapter)
        end

        relation
      end

      # Saves the relationship. This simply calls {#save} on every
      # member of the relationship.
      #
      # **This method typically won't be used except internally.**
      def save_relationship(caller, data)
        # Just call save on each nic with the VM
        data.each do |nic|
          nic.save(caller.name)
        end
      end
    end

    # Since there is currently no way to create a _new_ nic, this is
    # only used internally. Developers should NOT try to initialize their
    # own nic objects.
    def initialize(caller, data)
      super()

      @index = data["slot"].to_i + 1

      # Set the parent
      write_attribute(:parent, caller)

      # Convert each attribute value to a string
      attrs = {}
      data.attributes.each do |key, value|
        attrs[key] = value.to_s
      end

      populate_attributes(attrs)

      # The `nic` attribute is a bit more complicated, but not by
      # much
      if data["enabled"] == "true"
        write_attribute(:nic, data.children[1].name.downcase)
      else
        write_attribute(:nic, "none")
      end

      # Clear dirtiness
      clear_dirty!
    end

    # Saves a single attribute of the nic. This method is automatically
    # called on {#save}.
    #
    # **This method typically won't be used except internally.**
    def save_attribute(key, value, vmname)
      Command.vboxmanage("modifyvm", vmname, "--#{key}#{@index}", value)
      super
    end
  end
end