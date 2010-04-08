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
  #     attribute :description, :readonly => true
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
  #     attribute :ehci
  #     attribute :audio
  #     attribute :audiocontroller
  #     attribute :audiodriver
  #     attribute :vrdp
  #     attribute :vrdpport
  #     attribute :vrdpauthtype
  #     attribute :vrdpauthtimeout
  #     attribute :state, :populate_key => :vmstate, :readonly => true
  #
  # ## Relationships
  #
  # In addition to the basic attributes, a virtual machine is related
  # to other things. The relationships are listed below. If you don't
  # understand this, read {Relatable}.
  #
  #     relationship :nics, Nic
  #     relationship :usbs, USB
  #     relationship :storage_controllers, StorageController, :dependent => :destroy
  #     relationship :shared_folders, SharedFolder
  #     relationship :extra_data, ExtraData
  #     relationship :forwarded_ports, ForwardedPort
  #
  class VM < AbstractModel
    attribute :uuid, :readonly => true, :property => :id
    attribute :name
    attribute :os_type_id
    attribute :description, :readonly => true
    attribute :memory_size
    attribute :memory_balloon_size
    attribute :vram_size
    attribute :cpu_count
    attribute :accelerate_3d_enabled
    attribute :accelerate_2d_video_enabled
    attribute :clipboard_mode
    attribute :monitor_count
    attribute :state, :readonly => true
    attribute :accessible, :readonly => true
    attribute :hardware_version
    attribute :hardware_uuid
    attribute :statistics_update_interval
    attribute :firmware_type
    attribute :snapshot_folder
    attribute :settings_file_path, :readonly => true
    attribute :last_state_change, :readonly => true
    attribute :state_file_path, :readonly => true
    attribute :log_folder, :readonly => true
    attribute :snapshot_count, :readonly => true
    attribute :current_state_modified, :readonly => true
    attribute :guest_property_notification_patterns
    attribute :teleporter_enabled
    attribute :teleporter_port
    attribute :teleporter_address
    attribute :teleporter_password
    attribute :interface, :readonly => true, :property => false
    relationship :audio_adapter, :AudioAdapter
    relationship :bios, :BIOS
    relationship :storage_controllers, :StorageController, :dependent => :destroy
    relationship :medium_attachments, :MediumAttachment
    relationship :shared_folders, :SharedFolder
    relationship :extra_data, :ExtraData
    relationship :forwarded_ports, :ForwardedPort
    relationship :network_adapters, :NetworkAdapter
    relationship :usb_controller, :USBController

    class <<self
      # Returns an array of all available VMs.
      #
      # @return [Array<VM>]
      def all
        Global.global(true).vms
      end

      # Finds a VM by UUID or registered name and returns a
      # new VM object. If the VM doesn't exist, will return `nil`.
      #
      # @return [VM]
      def find(name)
        all.detect { |o| o.name == name || o.uuid == name }
      end

      # Imports a VM, blocking the entire thread during this time.
      # When finished, on success, will return the VM object. This
      # VM object can be used to make any modifications necessary
      # (RAM, cpus, etc.).
      #
      # If there are multiple VMs in the OVF file being imported,
      # the first virtual machine will be returned, although all will
      # be imported.
      #
      # @return [VM] The newly imported virtual machine
      def import(source_path, &block)
        appliance = Appliance.new(source_path)
        appliance.import(&block)

        find(appliance.virtual_systems.first.descriptions[:name][:auto])
      end

      def populate_relationship(caller, machines)
        result = Proxies::Collection.new(caller)

        machines.each do |machine|
          result << new(machine)
        end

        result
      end
    end

    # Creates a new instance of a virtual machine.
    #
    # **Currently can NOT be used to create a NEW virtual machine**.
    # Support for creating new virtual machines will be added shortly.
    # For now, this is only used by {VM.find} and {VM.all} to
    # initialize the VMs.
    def initialize(imachine)
      super()

      write_attribute(:interface, imachine)
      initialize_attributes(imachine)
    end

    def initialize_attributes(machine)
      # Load the interface attributes
      load_interface_attributes(machine)

      # Setup the relationships
      populate_relationships(machine)

      # Clear dirtiness, since this should only be called initially and
      # therefore shouldn't affect dirtiness
      clear_dirty!

      # But this is an existing record
      existing_record!
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
        load_interface_attribute(:state)
        clear_dirty!(:state)
      end

      read_attribute(:state)
    end

    # Saves the virtual machine if modified. This method saves any modified
    # attributes of the virtual machine. If any related attributes were saved
    # as well (such as storage controllers), those will be saved, too.
    def save
      with_open_session do |session|
        # Use setters to save the attributes on the locked machine and persist
        # the settings
        machine = session.machine

        # Save all the attributes and relationships
        save_changed_interface_attributes(machine)

        # Save relationships, which may open their own sessions if necessary
        save_relationships
      end
    end

    # Opens a direct session with the machine this VM represents and yields
    # the session object to a block. Many of the VirtualBox's settings can only
    # be modified with an open session on a machine. An open session is similar
    # to a write-lock. Once the session is completed, it must be closed, which
    # this method does as well.
    def with_open_session
      # Set the session up
      session = Lib.lib.session

      close_session = false

      if session.state != :open
        # Open up a session for this virtual machine
        interface.parent.open_session(session, uuid)

        # Mark the session to be closed
        close_session = true
      end

      # Yield the block with the session
      yield session

      # Close the session
      if close_session
        # Save these settings only if we're closing
        session.machine.save_settings

        # Close the session
        session.close
      end
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
    def export(filename)
      app = Appliance.new
      app.path = filename
      app.add_machine(self)
      app.export
    end

    # Starts the virtual machine. The virtual machine can be started in a
    # variety of modes:
    #
    # * **gui** -- The VirtualBox GUI will open with the screen of the VM.
    # * **vrdp** -- The VM will run in the background. No GUI will be
    #   present at all.
    #
    # This method blocks while the external processes are starting.
    #
    # @param [Symbol] mode Described above.
    # @return [Boolean] True if command was successful, false otherwise.
    def start(mode="gui")
      return false if running?

      # Open a new remote session, this will automatically start the machine
      # as well
      session = Lib.lib.session
      interface.parent.open_remote_session(session, uuid, mode.to_s, "").wait_for_completion(-1)

      # Close our session to release our lock from the machine
      session.close

      true
    end

    # Shuts down the VM by directly calling "acpipowerbutton". Depending on the
    # settings of the Virtual Machine, this may not work. For example, some linux
    # installations don't respond to the ACPI power button at all. In such cases,
    # {#stop} or {#save_state} may be used instead.
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def shutdown
      control(:power_button)
    end

    # Stops the VM by directly calling "poweroff." Immediately halts the
    # virtual machine without saving state. This could result in a loss
    # of data. To prevent data loss, see {#shutdown}
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def stop
      control(:power_down)
    end

    # Pauses the VM, putting it on hold temporarily. The VM can be resumed
    # again by calling {#resume}
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def pause
      control(:pause)
    end

    # Resume a paused VM.
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def resume
      control(:resume)
    end

    # Saves the state of a VM and stops it. The VM can be resumed
    # again by calling "{#start}" again.
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def save_state
      control(:save_state)
    end

    # Discards any saved state on the current VM. The VM is not destroyed though
    # and can still be started by calling {#start}.
    #
    # @return [Boolean] True if command was successful, false otherwise.
    def discard_state
      control(:forget_saved_state, true)
    end

    # Controls the virtual machine. This method is used by {#stop},
    # {#pause}, {#resume}, and {#save_state} to control the virtual machine.
    # Typically, you won't ever have to call this method and should
    # instead call those.
    #
    # @param [String] command The command to run on controlvm
    # @return [Boolean] True if command was successful, false otherwise.
    def control(command, *args)
      # Grab the session using an existing session
      session = Lib.lib.session
      interface.parent.open_existing_session(session, uuid)

      # Send the proper command, waiting if we have to
      result = session.console.send(command, *args)
      result.wait_for_completion(-1) if result.is_a?(COM::Interface::Progress)

      # Close the session
      session.close
    end

    # Destroys the virtual machine. This method also removes all attached
    # media (required by VirtualBox to destroy a VM). By default,
    # this **will not** destroy attached hard drives, but will if given
    # the `destroy_image` option.
    #
    # @overload destroy(opts = {})
    #   Passes options to the destroy method.
    #   @option opts [Boolean] :destroy_medium (false) If true, will
    #     also unregister attached media. If set to `:delete`, it will
    #     not only unregister attached media, but will also physically
    #     remove their respective data.
    def destroy(*args)
      # Call super first so destroy is propogated through to relationships
      # first
      super

      # Finally, destroy this machine and remove the settings file
      interface.parent.unregister_machine(uuid)
      interface.delete_settings
    end

    # Returns true if the virtual machine state is running
    #
    # @return [Boolean] True if virtual machine state is running
    def running?
      state == :running
    end

    # Returns true if the virtual machine state is powered off
    #
    # @return [Boolean] True if virtual machine state is powered off
    def powered_off?
      state == :powered_off
    end

    # Returns true if the virtual machine state is paused
    #
    # @return [Boolean] True if virtual machine state is paused
    def paused?
      state == :paused
    end

    # Returns true if the virtual machine state is saved
    #
    # @return [Boolean] True if virtual machine state is saved
    def saved?
      state == :saved
    end

    # Returns true if the virtual machine state is aborted
    #
    # @return [Boolean] True if virtual machine state is aborted
    def aborted?
      state == :aborted
    end
  end
end