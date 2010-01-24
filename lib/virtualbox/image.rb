require 'virtualbox/ext/subclass_listing'

module VirtualBox
  class Image < AbstractModel
    include SubclassListing
    
    attribute :uuid, :readonly => true
    attribute :location
    attribute :accessible, :readonly => true
    
    class <<self
      def parse_raw(raw)
        parse_blocks(raw).collect { |v| new(v) }
      end
      
      def parse_blocks(raw)
        raw.split(/\n\n/).collect { |v| parse_block(v.chomp) }.compact
      end
      
      def parse_block(block)
        return nil unless block =~ /^UUID:/i
        hd = {}

        # Parses each line which should be in the format:
        # KEY: VALUE
        block.lines.each do |line|
          next unless line =~ /^(.+?):\s+(.+?)$/
          hd[$1.downcase.to_sym] = $2.to_s
        end
        
        # If we don't have a location but have a path, use that, as they
        # are equivalent but not consistent.
        hd[:location] = hd[:path] if hd.has_key?(:path)
        
        hd
      end
      
      # Searches the subclasses which implement all method, searching for
      # a matching UUID and returning that as the relationship.
      def populate_relationship(caller, data)
        return nil if data[:uuid].nil?
        
        subclasses.each do |subclass|
          next unless subclass.respond_to?(:all)
          
          matching = subclass.all.find { |obj| obj.uuid == data[:uuid] }
          return matching unless matching.nil?
        end
      end
    end
    
    def initialize(info=nil)
      super()
      
      populate_attributes(info) if info
    end
  end
end