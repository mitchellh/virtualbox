module VirtualBox
  module Proxies
    # A relationship which can be described as a collection, which
    # is a set of items.
    class Collection < Array
      def initialize(parent)
        super()
        
        @parent = parent
      end
      
      def <<(item)
        item.added_to_relationship(@parent) if item.respond_to?(:added_to_relationship)
        push(item)
      end
      
      def clear
        each do |item|
          delete(item)
        end
      end
      
      def delete(item)
        return unless super
        item.removed_from_relationship(@parent) if item.respond_to?(:removed_from_relationship)
      end
    end
  end
end