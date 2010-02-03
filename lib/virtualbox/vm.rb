module VirtualBox
  # Represents a single VirtualBox virtual machine. All attributes which are
  # not read-only can be modified and saved.
  #
  # # Finding Virtual Machines
  #
  # Two methods are used to find virtual machines: {VM.all} and {VM.find}. Each
  # return a {VM} object. An example is shown below:
  #
  #     vm = VirtualBox::VM.find("MyWindowsXP")
  #     puts vm.name # => "MyWindowsXP"
  #
  # # Modifying Virtual Machines
  #
  # Virtual machines can be modified a lot like [ActiveRecord](http://ar.rubyonrails.org/)
  # objects. This is best shown through example:
  #
  #     vm = VirtualBox::VM.find("MyWindowsXP")
  #     vm.memory = 256
  #     vm.name = "WindowsXP"
  #     vm.save
  #
  # # Attributes and Relationships
  #
  # Properties of the virtual machine are exposed using standard ruby instance
  # methods which are generated on the fly. Because of this, they are not listed
  # below as available instance methods.
  #
  # These attributes can be accessed and modified via standard ruby-style
  # `instance.attribute` and `instance.attribute=` methods. The attributes are
  # listed below.
  #
  # Relationships are also accessed like attributes but can't be set. Instead,
  # they are typically references to other objects such as a {HardDrive} which
  # in turn have their own attributes which can be modified.
  #
  # ## Attributes
  #
  # This is copied directly from the class header, but lists all available
  # attributes. If you don't understand what this means, read {Attributable}.
  #
  #     attribute :uuid, :readonly => true
  #     attribute :name
  #     attribute :ostype
  #     attribute :memory
  #     attribute :vram
  #     attribute :acpi
  #     attribute :ioapic
  #     attribute :cpus
  #     attribute :synthcpu
  #     attribute :pae
  #     attribute :hwvirtex
  #     attribute :hwvirtexexcl
  #     attribute :nestedpaging
  #     attribute :vtxvpid
  #     attribute :accelerate3d
  #     attribute :accelerate2dvideo
  #     attribute :biosbootmenu, :populate_key => :bootmenu
  #     attribute :boot1
  #     attribute :boot2
  #     attribute :boot3
  #     attribute :boot4
  #     attribute :clipboard
  #     attribute :monitorcount
  #     attribute :usb
  #     attribute :audio
  #     attribute :vrdp
  #     attribute :vrdpports
  #     attribute :state, :populate_key => :vmstate, :readonly => true
  #
  # ## Relationships
  #
  # In addition to the basic attributes, a virtual machine is related
  # to other things. The relationships are listed below. If you don't
  # understand this, read {Relatable}.
  #
  #     relationship :nics, Nic
  #     relationship :storage_controllers, StorageController, :dependent => :destroy
  #     relationship :shared_folders, SharedFolder
  #     relationship :extra_data, ExtraData
  #     relationship :forwarded_ports, ForwardedPort
  #     relationship :snapshots, Snapshot, :dependent => :destroy
  #
  class VM < AbstractModel
    attribute :uuid, :readonly => true
    attribute :name
    attribute :ostype
    attribute :memory
    attribute :vram
    attribute :acpi
    attribute :ioapic
    attribute :cpus
    attribute :synthcpu
    attribute :pae
    attribute :hwvirtex
    attribute :hwvirtexexcl
    attribute :nestedpaging
    attribute :vtxvpid
    attribute :accelerate3d
    attribute :accelerate2dvideo
    attribute :biosbootmenu, :populate_key => :bootmenu
    attribute :boot1
    attribute :boot2
    attribute :boot3
    attribute :boot4
    attribute :clipboard
    attribute :monitorcount
    attribute :usb
    attribute :audio
    attribute :vrdp
    attribute :vrdpports
    attribute :state, :populate_key => :vmstate, :readonly => true
    relationship :nics, Nic
    relationship :storage_controllers, StorageController, :dependent => :destroy
    relationship :shared_folders, SharedFolder
    relationship :extra_data, ExtraData
    relationship :forwarded_ports, ForwardedPort
    relationship :snapshots, Snapshot, :dependent => :destroy

    class <<self
      # Returns an array of all available VMs.
      #
      # @return [Array<VM>]
      def all
        raw = Command.vboxmanage("list", "vms")
        parse_vm_list(raw)
      end

      # Finds a VM by UUID or registered name and returns a
      # new VM object. If the VM doesn't exist, will return `nil`.
      #
      # @return [VM]
      def find(name)
        new(raw_info(name))
      rescue Exceptions::CommandFailedException
        nil
      end

      # Imports a VM, blocking the entire thread during this time.
      # When finished, on success, will return the VM object. This
      # VM object can be used to make any modifications necessary
      # (RAM, cpus, etc.).
      #
      # @return [VM] The newly imported virtual machine
      def import(source_path)
        raw = Command.vboxmanage("import", source_path)
        return nil unless raw

        find(parse_vm_name(raw))
      end

      # Gets the non-machine-readable info for a given VM and returns
      # it as a raw string.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [String]
      def human_info(name)
        Command.vboxmanage("showvminfo", name)
      end

      # Gets the VM info (machine readable) for a given VM and returns it
      # as a hash.
      #
      # @return [Hash] Parsed VM info.
      def raw_info(name)
        raw = Command.vboxmanage("showvminfo", name, "--machinereadable")
        parse_vm_info(raw)
      end

      # Parses the machine-readable format outputted by VBoxManage showvminfo
      # into a hash. Ignores lines which don't match the format.
      def parse_vm_info(raw)
        parsed = {}
        raw.split("\n").each do |line|
          # Some lines aren't configuration, we just ignore them
          next unless line =~ /^"?(.+?)"?="?(.+?)"?$/
          parsed[$1.downcase.to_sym] = $2.strip
        end

        parsed
      end

      # Parses the list of VMs returned by the "list vms" command used
      # in {VM.all}.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [Array] Array of virtual machines.
      def parse_vm_list(raw)
        results = []
        raw.split("\n").each do |line|
          next unless line =~ /^"(.+?)"\s+\{(.+?)\}$/
          results.push(find($1.to_s))
        end

        results
      end

      # Parses the vm name from the import results.
      #
      # **This method typically won't be used except internally.**
      #
      # @return [String] Parsed VM name
      def parse_vm_name(raw)
        return nil unless raw =~ /VM name "(.+?)"/
        $1.to_s
      end
    end

    # Creates a new instance of a virtual machine.
    #
    # **Currently can NOT be used to create a NEW virtual machine**.
    # Support for creating new virtual machines will be added shortly.
    # For now, this is only used by {VM.find} and {VM.all} to
    # initialize the VMs.
    def initialize(data)
      super()

      populate_attributes(data)
      @original_name = data[:name]
    end

    # State of the virtual machine. Returns the state of the virtual
    # machine. This state will represent the state that was assigned
    # when the VM was found unless `reload` is set to `true`.
    #
    # @param [Boolean] reload If true, will reload the state to current
    #   value.
    # @return [String] Virtual machine state.
    def state(reload=false)
      if reload
        info = self.class.raw_info(@original_name)
        write_attribute(:state, info[:vmstate])
      end

      read_attribute(:state)
    end

    # Saves the virtual machine if modified. This method saves any modified
    # attributes of the virtual machine. If any related attributes were saved
    # as well (such as storage controllers), those will be saved, too.
    def save(raise_errors=false)
      # Make sure we save the new name first if that was changed, or
      # we'll get some inconsistencies later
      if name_changed?
        save_attribute(:name, name)
        @original_name = name
      end

      super()

      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      return false
    end

    # Saves a single attribute of the virtual machine. This should **not**
    # be called except interally. Instead, you're probably looking for {#save}.
    #
    # **This method typically won't be used except internally.**
    def save_attribute(key, value)
      Command.vboxmanage("modifyvm", @original_name, "--#{key}", value)
      super
    end

    # Exports a virtual machine. The virtual machine will be exported
    # to the specified OVF file name. This directory will also have the
    # `mf` file which contains the file checksums and also the virtual
    # drives of the machine.
    #
    # Export also supports an additional options hash which can contain
    # information that will be embedded with the virtual machine. View
    # below for more information on the available options.
    #
    # This method will block until the export is complete, which takes about
    # 60 to 90 seconds on my 2.2 GHz 2009 model MacBook Pro.
    #
    # @param [String] filename The file (not directory) to save the exported
    #   OVF file. This directory will also receive the checksum file and
    #   virtual disks.
    # @option options [String] :product (nil) The name of the product
    # @option options [String] :producturl (nil) The URL of the product
    # @option options [String] :vendor (nil) The name of the vendor
    # @option options [String] :vendorurl (nil) The URL for the vendor
    # @option options [String] :version (nil) The version information
    # @option options [String] :eula (nil) License text
    # @option options [String] :eulafile (nil) License file
    def export(filename, options={}, raise_error=false)
      options = options.inject([]) do |acc, kv|
        acc.push("--#{kv[0]}")
        acc.push(kv[1])
      end

      options.unshift("0").unshift("--vsys") unless options.empty?

      raw = Command.vboxmanage("export", @original_name, "-o", filename, *options)
      true
    rescue Exceptions::CommandFailedException
      raise if raise_error
      false
    end

    # Starts the virtual machine. The virtual machine can be started in a
    # variety of modes:
    #
    # * **gui** -- The VirtualBox GUI will open with the screen of the VM.
    # * **headless** -- The VM will run in the background. No GUI will be
    #   present at all.
    #
    # All modes will start their processes and return almost immediately.
    # Both the GUI and headless mode will not block the ruby process.
    #
    # @param [Symbol] mode Described above.
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def start(mode=:gui, raise_errors=false)
      Command.vboxmanage("startvm", @original_name, "--type", mode)
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end

    # Shuts down the VM by directly calling "acpipowerbutton". Depending on the
    # settings of the Virtual Machine, this may not work. For example, some linux
    # installations don't respond to the ACPI power button at all. In such cases,
    # {#stop} or {#save_state} may be used instead.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def shutdown(raise_errors=false)
      control(:acpipowerbutton, raise_errors)
    end

    # Stops the VM by directly calling "poweroff." Immediately halts the
    # virtual machine without saving state. This could result in a loss
    # of data. To prevent data loss, see {#shutdown}
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def stop(raise_errors=false)
      control(:poweroff, raise_errors)
    end

    # Pauses the VM, putting it on hold temporarily. The VM can be resumed
    # again by calling {#resume}
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def pause(raise_errors=false)
      control(:pause, raise_errors)
    end

    # Resume a paused VM.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def resume(raise_errors=false)
      control(:resume, raise_errors)
    end

    # Saves the state of a VM and stops it. The VM can be resumed
    # again by calling "{#start}" again.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def save_state(raise_errors=false)
      control(:savestate, raise_errors)
    end

    # Discards any saved state on the current VM. The VM is not destroyed though
    # and can still be started by calling {#start}.
    #
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def discard_state(raise_errors=false)
      Command.vboxmanage("discardstate", @original_name)
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end

   	# Take a snapshot. This will take a copy of the settings of the virtual
   	# machine at the moment it was taken. If the VM was running at the time,
   	# it also stores the state of the machine. This will also create a
   	# differencing hard disk for each normal hard disk attached to the VM so
   	# that when the snapshot is restored later, the hard drives can be brought
   	# back to their proper state.
    #
    # @param [String] name Name of snapshot.
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def snapshot(name, raise_errors=false)
      Command.vboxmanage("snapshot", @original_name, "take", name)
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end

    # Controls the virtual machine. This method is used by {#stop},
    # {#pause}, {#resume}, and {#save_state} to control the virtual machine.
    # Typically, you won't ever have to call this method and should
    # instead call those.
    #
    # @param [String] command The command to run on controlvm
    # @param [Boolean] raise_errors If true, {Exceptions::CommandFailedException}
    #   will be raised if the command failed.
    # @return [Boolean] True if command was successful, false otherwise.
    def control(command, raise_errors=false)
      Command.vboxmanage("controlvm", @original_name, command)
      true
    rescue Exceptions::CommandFailedException
      raise if raise_errors
      false
    end

    # Destroys the virtual machine. This method also removes all attached
    # media (required by VirtualBox to destroy a VM). By default,
    # this **will not** destroy attached hard drives, but will if given
    # the `destroy_image` option.
    #
    # @overload destroy(opts = {})
    #   Passes options to the destroy method.
    #   @option opts [Boolean] :destroy_image (false) If true, will
    #     also destroy all attached images such as hard drives, disk
    #     images, etc.
    def destroy(*args)
      # Call super first to destroy relationships, necessary before
      # unregistering a VM
      super

      Command.vboxmanage("unregistervm", @original_name, "--delete")
    end

    # Returns true if the virtual machine state is running
    #
    # @return [Boolean] True if virtual machine state is running
    def running?
      state == 'running'
    end

    # Returns true if the virtual machine state is powered off
    #
    # @return [Boolean] True if virtual machine state is powered off
    def powered_off?
      state == 'poweroff'
    end

    # Returns true if the virtual machine state is paused
    #
    # @return [Boolean] True if virtual machine state is paused
    def paused?
      state == 'paused'
    end

    # Returns true if the virtual machine state is saved
    #
    # @return [Boolean] True if virtual machine state is saved
    def saved?
      state == 'saved'
    end

    # Returns true if the virtual machine state is aborted
    #
    # @return [Boolean] True if virtual machine state is aborted
    def aborted?
      state == 'aborted'
    end
  end
end