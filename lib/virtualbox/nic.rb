module VirtualBox
  class Nic < AbstractModel
    attribute :parent, :readonly => :readonly
    attribute :nic
    attribute :nictype
    attribute :macaddress
    attribute :cableconnected
    attribute :bridgeadapter
    
    class <<self
      # Some data is not exposed in the machine readable showvminfo yet,
      # such as nic type. We must therefore parse the human readable stuff.
      def nic_data(vmname)
        raw = VM.human_info(vmname)
        
        # Complicated chain of methods just maps parse_nic over each line,
        # removing invalid ones, and then converting it into a single hash.
        raw.lines.collect { |v| parse_nic(v) }.compact.inject({}) do |acc, obj|
          acc.merge({ obj[0] => obj[1] })
        end
      end
      
      # Parses nic data out of a single line of the human readable output
      # of VBoxManage
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
      
      def populate_relationship(caller, data)
        nic_data = nic_data(caller.name)
        
        relation = []
        
        counter = 1
        loop do
          break unless data["nic#{counter}".to_sym]
          
          nictype = nic_data["nic#{counter}".to_sym][:type] rescue nil
          
          nic = new(counter, caller, data.merge({
            "nictype#{counter}".to_sym => nictype
          }))
          relation.push(nic)
          counter += 1
        end
        
        relation
      end
      
      def save_relationship(caller, data)
        # Just call save on each nic with the VM
        data.each do |nic|
          nic.save(caller.name)
        end
      end
    end
    
    def initialize(index, caller, data)
      super()
      
      @index = index
      
      # Setup the index specific attributes
      populate_data = {}
      self.class.attributes.each do |name, options|
        value = data["#{name}#{index}".to_sym]
        populate_data[name] = value
      end
      
      populate_attributes(populate_data.merge({
        :parent => caller
      }))
    end
    
    def save_attribute(key, value, vmname)
      Command.vboxmanage("modifyvm #{vmname} --#{key}#{@index} #{Command.shell_escape(value)}")
      super
    end
  end
end