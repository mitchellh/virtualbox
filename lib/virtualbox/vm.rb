module VirtualBox
  class VM
    class <<self
      # Finds a VM by UUID or registered name and returns a
      # new VM object
      def find(name)
        raw = Command.vboxmanage("showvminfo #{name} --machinereadable")
        new(parse_vm_info(raw))
      end
      
      def parse_vm_info(raw)
        parsed = {}

        raw.lines.each do |line|
          # Some lines aren't configuration, we just ignore them
          next unless line =~ /^"?(.+?)"?="?(.+?)"?$/
          parsed[$1] = $2.strip
        end

        parsed
      end
    end
    
    def initialize(data)
      
    end
  end
end