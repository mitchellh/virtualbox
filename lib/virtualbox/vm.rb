module VirtualBox
  class VM < AbstractModel
    attribute :uuid, :readonly => true
    attribute :name
    attribute :ostype
    attribute :memory
    attribute :vram
    attribute :acpi
    attribute :cpus
    attribute :synthcpu
    attribute :pae
    attribute :hwvirtex
    attribute :hwvirtexexcl
    attribute :nestedpaging
    attribute :accelerate3d
    attribute :biosbootmenu, :populate_key => :bootmenu
    attribute :state, :populate_key => :vmstate, :readonly => true
    relationship :nics, Nic
    relationship :storage_controllers, StorageController, :dependent => :destroy
    
    class <<self
      # Returns an array of all available VMs.
      def all
        raw = Command.vboxmanage("list vms")
        parse_vm_list(raw)
      end
      
      # Finds a VM by UUID or registered name and returns a
      # new VM object
      def find(name)
        new(raw_info(name))
      end
      
      # Imports a VM, blocking the entire thread during this time. 
      # When finished, on success, will return the VM object. This
      # VM object can be used to make any modifications necessary
      # (RAM, cpus, etc.)
      def import(source_path)
        raw = Command.vboxmanage("import #{Command.shell_escape(source_path)}")
        return nil unless raw
        
        find(parse_vm_name(raw))
      end
      
      # Gets the non-machine-readable info for a given VM
      def human_info(name)
        Command.vboxmanage("showvminfo #{name}")
      end
      
      # Gets the VM info (machine readable) for a given VM
      def raw_info(name)
        raw = Command.vboxmanage("showvminfo #{name} --machinereadable")
        parse_vm_info(raw)
      end
      
      # Parses the machine-readable format outputted by VBoxManage showvminfo
      # into a hash. Ignores lines which don't match the format.
      def parse_vm_info(raw)
        parsed = {}
        raw.lines.each do |line|
          # Some lines aren't configuration, we just ignore them
          next unless line =~ /^"?(.+?)"?="?(.+?)"?$/
          parsed[$1.downcase.to_sym] = $2.strip
        end

        parsed
      end
      
      # Parses the list of VMs
      def parse_vm_list(raw)
        results = []
        raw.lines.each do |line|
          next unless line =~ /^"(.+?)"\s+\{(.+?)\}$/
          results.push(find($1.to_s))
        end
        
        results
      end
      
      # Parses the vm name from the import results
      def parse_vm_name(raw)
        return nil unless raw =~ /VM name "(.+?)"/
        $1.to_s
      end
    end
    
    def initialize(data)
      super()
      
      populate_attributes(data)
      @original_name = data[:name]
    end
    
    # Reading state is a special case
    def state(reload=false)
      if reload
        info = self.class.raw_info(@original_name)
        write_attribute(:state, info[:vmstate])
      end
      
      read_attribute(:state)
    end
    
    def save
      # Make sure we save the new name first if that was changed, or
      # we'll get some inconsistencies later
      if name_changed?
        save_attribute(:name, name)
        @original_name = name
      end
      
      super
    end
    
    def save_attribute(key, value)
      Command.vboxmanage("modifyvm #{@original_name} --#{key} #{Command.shell_escape(value.to_s)}")
      super
    end
    
    def start(type=:gui)
      Command.vboxmanage("startvm #{@original_name} --type #{type}")
    end
    
    # Stops the VM by directly calling "poweroff"
    def stop
      Command.vboxmanage("controlvm #{@original_name} poweroff")
    end
    
    def destroy(*args)
      # Call super first to destroy relationships, necessary before
      # unregistering a VM
      super
      
      Command.vboxmanage("unregistervm #{@original_name} --delete")
    end
  end
end