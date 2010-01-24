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
    relationship :nics, Nic
    
    class <<self
      # Finds a VM by UUID or registered name and returns a
      # new VM object
      def find(name)
        raw = Command.vboxmanage("showvminfo #{name} --machinereadable")
        new(parse_vm_info(raw))
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
    end
    
    def initialize(data)
      super()
      
      populate_attributes(data)
      @original_name = data[:name]
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
      Command.vboxmanage("modifyvm #{@original_name} --#{key} #{Command.shell_escape(value)}")
      super
    end
  end
end