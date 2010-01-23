module VirtualBox
  class HardDrive
    REQUIRED_FIELDS = [:uuid, :format, :location, :accessible]
    attr_reader :uuid, :format, :location, :accessible

    class <<self
      # Returns an array of all available hard drives as HardDrive
      # objects
      def all
        raw = Command.vboxmanage("list hdds")
        raw.split(/\n\n/).collect { |v| create_from_block(v) }.compact
      end
      
      # Parses a hard drive from the VBoxManage list format
      # given.
      def create_from_block(block)
        return nil unless block =~ /^UUID:/i
        hd = {}

        # Parses each line which should be in the format:
        # KEY: VALUE
        block.lines.each do |line|
          next unless line =~ /^(.+?):\s+(.+?)$/
          hd[$1.downcase.to_sym] = $2.to_s
        end
        
        # Make sure we got all the required keys
        return nil unless (REQUIRED_FIELDS - hd.keys).empty?
        
        # Create the object
        new(hd)
      end
    end
    
    def initialize(info)
      REQUIRED_FIELDS.each do |field|
        instance_variable_set("@#{field}".to_sym, info[field])
      end
    end
  end
end