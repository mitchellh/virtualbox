module VirtualBox
  class HardDrive < Image
    attribute :format, :default => "VDI"
    attribute :size
    
    class <<self
      # Returns an array of all available hard drives as HardDrive
      # objects
      def all
        raw = Command.vboxmanage("list hdds")
        parse_blocks(raw).collect { |v| find(v[:uuid]) }
      end
      
      # Finds one specific hard drive by UUID or file name
      def find(id)
        raw = Command.vboxmanage("showhdinfo #{id}")
        
        # Return nil if the hard drive doesn't exist
        return nil if raw =~ /VERR_FILE_NOT_FOUND/
        
        data = raw.split(/\n\n/).collect { |v| parse_block(v) }.find { |v| !v.nil? }
        
        # Set equivalent fields
        data[:format] = data[:"storage format"]
        data[:size] = data[:"logical size"].split(/\s+/)[0] if data.has_key?(:"logical size")
        
        # Return new object
        new(data)
      end
    end
    
    def clone(outputfile, format="VDI")
      raw = Command.vboxmanage("clonehd #{uuid} #{Command.shell_escape(outputfile)} --format #{format} --remember")
      return nil unless raw =~ /UUID: (.+?)$/
      
      self.class.find($1.to_s)
    end
    
    def create
      raw = Command.vboxmanage("createhd --filename #{location} --size #{size} --format #{read_attribute(:format)} --remember")
      return nil unless raw =~ /UUID: (.+?)$/
      
      # Just replace our attributes with the newly created ones. This also
      # will set new_record to false.
      populate_attributes(self.class.find($1.to_s).attributes)
    end
    
    def save
      if new_record?
        # Create a new hard drive
        create
      else
        super
      end
    end
    
    def destroy
      Command.vboxmanage("closemedium disk #{uuid} --delete")
      return $?.to_i == 0
    end
  end
end